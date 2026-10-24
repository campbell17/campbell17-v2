import AppKit
import SwiftUI
import Carbon
import Combine

final class GeeseHostingView<Content: View>: NSHostingView<Content> {
    override var mouseDownCanMoveWindow: Bool { true }
}

final class GeeseWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override func cancelOperation(_ sender: Any?) { orderOut(nil) }
    override func orderOut(_ sender: Any?) {
        saveWindowFrame()
        super.orderOut(sender)
        updateSwitcherPresence()
    }
    override func close() {
        saveWindowFrame()
        super.close()
        updateSwitcherPresence()
    }
    func bringToFrontAfterMigration() {
        guard isVisible else { return }
        NSApp.activate(ignoringOtherApps: true)
        makeKeyAndOrderFront(nil)
    }
    private func updateSwitcherPresence() {
        if !isVisible { NSApp.setActivationPolicy(.accessory) }
    }
    private func saveWindowFrame() {
        if !frameAutosaveName.isEmpty { saveFrame(usingName: frameAutosaveName) }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSToolbarDelegate, NSMenuDelegate {
    private var status: NSStatusItem!
    private var panel: GeeseWindow!
    private var hotKey: EventHotKeyRef?
    private let shortcuts = ShortcutPreferences()
    private var eventHandler: EventHandlerRef?
    private var model: GeeseModel!
    private var permissionObserver: AnyCancellable?
    private let updates = GeeseUpdates()
    private let titleItemID = NSToolbarItem.Identifier("GeeseTitle")
    private let settingsItemID = NSToolbarItem.Identifier("GeeseSettings")

    func applicationDidFinishLaunching(_ notification: Notification) {
        let menu = NSMenu()
        let applicationItem = NSMenuItem()
        let applicationMenu = NSMenu(title: "Geese")
        applicationMenu.addItem(withTitle: "About Geese", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        let updateItem = applicationMenu.addItem(withTitle: "Check for Updates…", action: #selector(checkForUpdates), keyEquivalent: "")
        updateItem.target = self
        applicationMenu.addItem(.separator())
        applicationMenu.addItem(withTitle: "Hide Geese", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        applicationMenu.addItem(withTitle: "Quit Geese", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        applicationItem.submenu = applicationMenu
        menu.addItem(applicationItem)
        NSApp.mainMenu = menu
        model = GeeseModel()
        model.onIconChanged = { [weak self] _ in self?.applyAppIcon() }
        applyAppIcon()
        permissionObserver = model.$trusted.removeDuplicates().sink { trusted in
            UserDefaults.standard.set(trusted, forKey: "lastAppAccessibilityGranted")
        }
        panel = GeeseWindow(contentRect: NSRect(x: 0, y: 0, width: 940, height: 720),
                           styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
        panel.title = "Geese"
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.backgroundColor = GeeseTheme.chromeColor
        panel.toolbarStyle = .unified
        panel.isMovableByWindowBackground = true
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.level = model.pinned ? .floating : .normal
        model.onPinChanged = { [weak self] pinned in
            self?.panel.level = pinned ? .floating : .normal
        }
        model.onMigrationFinished = { [weak self] in
            self?.panel.bringToFrontAfterMigration()
        }
        panel.contentView = GeeseHostingView(rootView: GeeseView(model: model))
        let toolbar = NSToolbar(identifier: "GeeseToolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = false
        toolbar.showsBaselineSeparator = false
        toolbar.centeredItemIdentifiers = [titleItemID]
        if #available(macOS 15.0, *) { toolbar.allowsDisplayModeCustomization = false }
        panel.toolbar = toolbar
        panel.contentMinSize = NSSize(width: 900, height: 440)
        let frameName = "GeeseMainWindow"
        panel.setFrameAutosaveName(frameName)
        if !panel.setFrameUsingName(frameName) { panel.center() }
        status = NSStatusBar.system.statusItem(withLength: 32)
        let menuIcon = NSImage(named: "GeeseMenuAlt")
        menuIcon?.isTemplate = true
        menuIcon?.size = NSSize(width: 18 * 69.58 / 57.1, height: 18)
        status.button?.image = menuIcon
        status.button?.setAccessibilityLabel("Geese")
        status.button?.target = self
        status.button?.action = #selector(statusClicked(_:))
        status.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        status.button?.toolTip = "Geese · \(shortcuts.shortcut.label)"
        installHotKey()
        updates.start()
        show()
        if !model.trusted && !UserDefaults.standard.bool(forKey: "requestedPersistentSigningAccess") {
            UserDefaults.standard.set(true, forKey: "requestedPersistentSigningAccess")
            model.requestAccess()
        }
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.flexibleSpace, titleItemID, .flexibleSpace, settingsItemID]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier identifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let item = NSToolbarItem(itemIdentifier: identifier)
        item.isBordered = false
        if identifier == titleItemID {
            item.label = "Geese"
            let titleView = GeeseHostingView(rootView: GeeseTitleView(model: model))
            titleView.frame = NSRect(x: 0, y: 0, width: 132, height: 32)
            item.view = titleView
        } else if identifier == settingsItemID {
            item.label = "Settings"
            let settingsView = NSHostingView(rootView: GeeseSettingsView(model: model, updates: updates, shortcuts: shortcuts, changeShortcut: { [weak self] in self?.editShortcut() }))
            settingsView.frame = NSRect(x: 0, y: 0, width: 36, height: 32)
            item.view = settingsView
        } else { return nil }
        return item
    }

    private func installHotKey() {
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let result = InstallEventHandler(GetApplicationEventTarget(), { _, _, context in
            guard let context else { return OSStatus(eventNotHandledErr) }
            let delegate = Unmanaged<AppDelegate>.fromOpaque(context).takeUnretainedValue()
            MainActor.assumeIsolated { delegate.toggle() }
            return noErr
        }, 1, &spec, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
        guard result == noErr else { model.message = "Could not register the shortcut. Use the menu bar icon."; return }
        if !registerShortcut(shortcuts.shortcut) {
            model.message = "\(shortcuts.shortcut.label) is unavailable. Choose another shortcut in Settings."
        }
    }

    private func registerShortcut(_ shortcut: GeeseShortcut) -> Bool {
        let identifier = EventHotKeyID(signature: 0x47454553, id: 1)
        return RegisterEventHotKey(shortcut.keyCode, shortcut.modifiers, identifier,
                                  GetApplicationEventTarget(), 0, &hotKey) == noErr
    }

    @objc private func editShortcut() {
        if let hotKey { UnregisterEventHotKey(hotKey); self.hotKey = nil }
        defer {
            if hotKey == nil && !registerShortcut(shortcuts.shortcut) {
                model.message = "Shortcut unavailable. Choose another shortcut in Settings."
            }
            status.button?.toolTip = "Geese · \(shortcuts.shortcut.label)"
        }
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "Keyboard Shortcut"
        alert.informativeText = "Click the field, then press your shortcut to show or hide Geese."
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Reset to Default")
        let field = ShortcutRecordButton(frame: NSRect(x: 0, y: 0, width: 300, height: 36))
        var candidate = shortcuts.shortcut
        field.title = candidate.label
        field.onStart = { alert.buttons[0].isEnabled = false }
        alert.accessoryView = field
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard field.recording else { return event }
            if event.keyCode == 53 && event.modifierFlags.intersection([.command, .control, .option, .shift]).isEmpty {
                field.recording = false
                field.title = candidate.label
                alert.buttons[0].isEnabled = true
                return nil
            }
            guard let value = GeeseShortcut(event: event) else {
                alert.informativeText = "Include Command, Control, or Option in your shortcut."
                return nil
            }
            candidate = value
            field.title = value.label
            field.recording = false
            alert.buttons[0].isEnabled = true
            alert.informativeText = "Click Save to use this shortcut."
            return nil
        }
        defer { if let monitor { NSEvent.removeMonitor(monitor) } }
        while true {
            let response = alert.runModal()
            if response == .alertSecondButtonReturn { return }
            if response == .alertThirdButtonReturn { candidate = .standard }
            field.recording = false
            field.title = candidate.label
            alert.buttons[0].isEnabled = true
            if registerShortcut(candidate) {
                shortcuts.save(candidate)
                return
            }
            alert.informativeText = "That shortcut is unavailable. Click the field and try another combination."
        }
    }

    @objc func toggle() {
        if panel.isVisible && panel.isKeyWindow { panel.orderOut(nil) }
        else { show() }
    }

    @objc private func statusClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            if !model.busy { model.refreshDesktopList() }
            let menu = NSMenu()
            menu.autoenablesItems = false
            let heading = menu.addItem(withTitle: "Fly to this pond", action: nil, keyEquivalent: "")
            heading.isEnabled = false
            let displayIDs = model.desktops.reduce(into: [String]()) { result, desktop in
                if !result.contains(desktop.display) { result.append(desktop.display) }
            }
            for display in displayIDs {
                if displayIDs.count > 1 {
                    let label = menu.addItem(withTitle: model.displayName(display), action: nil, keyEquivalent: "")
                    label.isEnabled = false
                }
                for desktop in model.desktops where desktop.display == display {
                    let item = menu.addItem(withTitle: model.name(desktop), action: #selector(moveFromMenu(_:)), keyEquivalent: "")
                    item.target = self
                    item.representedObject = NSNumber(value: desktop.id)
                    item.indentationLevel = displayIDs.count > 1 ? 1 : 0
                    item.state = model.flockDesktopID == desktop.id ? .on : .off
                    item.isEnabled = !model.busy && model.available && model.trusted && model.flockDesktopID != desktop.id
                }
            }
            if model.desktops.isEmpty {
                let empty = menu.addItem(withTitle: "No desktops found", action: nil, keyEquivalent: "")
                empty.isEnabled = false
            }
            menu.addItem(.separator())
            let pin = menu.addItem(withTitle: "Pin window", action: #selector(togglePin), keyEquivalent: "")
            pin.target = self
            pin.state = model.pinned ? .on : .off
            let follow = menu.addItem(withTitle: "Follow windows", action: #selector(toggleFollow), keyEquivalent: "")
            follow.target = self
            follow.state = model.follow ? .on : .off
            let refresh = menu.addItem(withTitle: "Refresh", action: #selector(refreshFromMenu), keyEquivalent: "")
            refresh.target = self
            let access = menu.addItem(withTitle: "Accessibility Settings…", action: #selector(openAccessSettings), keyEquivalent: "")
            access.target = self
            let iconMenu = NSMenu(title: "App icon")
            for style in GeeseIconStyle.allCases {
                let item = iconMenu.addItem(withTitle: style.title, action: #selector(changeIcon(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = style.rawValue
                item.state = model.iconStyle == style ? .on : .off
                item.image = style.menuImage
            }
            let iconItem = menu.addItem(withTitle: "App icon", action: nil, keyEquivalent: "")
            iconItem.submenu = iconMenu
            let update = menu.addItem(withTitle: "Check for Updates…", action: #selector(checkForUpdates), keyEquivalent: "")
            update.target = self
            update.isEnabled = updates.canCheck
            menu.addItem(.separator())
            let version = menu.addItem(withTitle: GeeseUpdates.versionDescription, action: nil, keyEquivalent: "")
            version.isEnabled = false
            let shortcut = menu.addItem(withTitle: "Keyboard Shortcut… (\(shortcuts.shortcut.label))", action: #selector(editShortcut), keyEquivalent: "")
            shortcut.target = self
            let quit = menu.addItem(withTitle: "Quit Geese", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
            quit.target = NSApp
            // Let the status bar anchor and size its menu below the menu bar.
            // A contextual popup anchors to an item and can begin scrolled.
            menu.delegate = self
            status.menu = menu
            sender.performClick(nil)
        } else {
            toggle()
        }
    }

    func menuDidClose(_ menu: NSMenu) {
        if status.menu === menu { status.menu = nil }
    }

    @objc private func moveFromMenu(_ sender: NSMenuItem) {
        guard !model.busy, let id = sender.representedObject as? NSNumber else { return }
        model.refreshDesktopList()
        guard let desktop = model.desktops.first(where: { $0.id == id.uint64Value }) else {
            model.issues = ["That desktop is no longer available."]
            show()
            return
        }
        Task { @MainActor in
            await model.migrate(to: desktop)
            if !model.issues.isEmpty { show() }
        }
    }

    @objc private func changeIcon(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String, let style = GeeseIconStyle(rawValue: raw) else { return }
        model.iconStyle = style
    }
    @objc private func checkForUpdates() { updates.check() }
    @objc private func togglePin() { model.pinned.toggle() }
    @objc private func toggleFollow() { model.follow.toggle() }
    @objc private func refreshFromMenu() { model.refresh() }
    @objc private func openAccessSettings() { model.requestAccess() }

    private func applyAppIcon() {
        guard let image = model?.iconStyle.image else { return }
        NSApp.applicationIconImage = image
        NSApp.dockTile.display()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        applyAppIcon()
    }

    func show() {
        model.refresh()
        NSApp.setActivationPolicy(.regular)
        applyAppIcon()
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        // Dock registration may finish after the activation-policy change.
        DispatchQueue.main.async { [weak self] in self?.applyAppIcon() }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        show()
        return true
    }
}

if CommandLine.arguments.contains("--diagnose") {
    print("Private window APIs: \(GAvailable() ? "available" : "missing")")
    print("Accessibility: \(AXIsProcessTrusted() ? "allowed" : "not yet allowed")")
    let displays = GDisplays() as? [[String: Any]] ?? []
    print("Displays: \(displays.count)")
    for (index, display) in displays.enumerated() {
        let spaces = display["Spaces"] as? [[String: Any]] ?? []
        let desktops = spaces.filter { ($0["type"] as? NSNumber)?.intValue == 0 }
        print("Display \(index + 1): \(desktops.count) regular desktops, \(spaces.count - desktops.count) full-screen spaces")
    }
    if AXIsProcessTrusted() {
        MainActor.assumeIsolated {
            let model = GeeseModel()
            let skipped = model.windows.filter { $0.skipReason != nil }
            print("Selected windows: \(model.windows.count); skipped: \(skipped.count)")
            for window in skipped {
                if let reason = window.skipReason { print("\(window.appName): \(reason)") }
            }
        }
    }
    exit(GAvailable() && !displays.isEmpty ? 0 : 1)
}

if CommandLine.arguments.contains("--switch-test") {
    MainActor.assumeIsolated {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let model = GeeseModel()
        guard let source = model.desktops.first(where: { $0.current }),
              let target = model.desktops.last(where: { $0.display == source.display && $0.id != source.id }) else { exit(2) }
        Task { @MainActor in
            let before = model.spaceChangeSerial
            let switched = await model.switchDesktop(target)
            let outNotifications = model.spaceChangeSerial - before
            let restored = await model.switchDesktop(source)
            print("Native destination transition: \(switched)")
            print("Real workspace notifications: \(outNotifications)")
            print("Original desktop restored: \(restored)")
            exit(switched && restored && outNotifications > 0 ? 0 : 1)
        }
        app.run()
    }
}

if CommandLine.arguments.contains("--fixture") {
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    let windows = (0..<2).map { index in
        let window = NSWindow(contentRect: NSRect(x: 120 + index * 40, y: 140 + index * 40, width: 260, height: 120),
                              styleMask: [.titled], backing: .buffered, defer: false)
        window.title = "Geese test fixture \(index + 1)"
        window.isReleasedWhenClosed = false
        window.orderFront(nil)
        return window
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        print("\(windows[0].windowNumber),\(windows[1].windowNumber)")
        fflush(stdout)
    }
    app.run()
}

if CommandLine.arguments.contains("--cross-process-test") {
    MainActor.assumeIsolated {
        _ = NSApplication.shared
        let pipe = Pipe()
        let helper = Process()
        helper.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
        helper.arguments = ["--fixture"]
        helper.standardOutput = pipe
        do { try helper.run() } catch { fputs("FAIL: fixture launch failed\n", stderr); exit(1) }
        var line = Data()
        while line.count < 100 {
            let next = pipe.fileHandleForReading.readData(ofLength: 1)
            if next.isEmpty || next.first == 10 { break }
            line.append(next)
        }
        let ids = String(data: line, encoding: .utf8)?.split(separator: ",").compactMap { UInt32($0) } ?? []
        guard ids.count == 2 else { helper.terminate(); helper.waitUntilExit(); exit(1) }
        let id = ids[0], fixedID = ids[1]
        let origin = (GWindowSpaces(id) ?? []).map(\.uint64Value)
        let fixedOrigin = (GWindowSpaces(fixedID) ?? []).map(\.uint64Value)
        let model = GeeseModel()
        guard let source = model.desktops.first(where: { $0.id == origin.first }),
              let target = model.desktops.first(where: { $0.display == source.display && $0.id != source.id }) else {
            helper.terminate(); helper.waitUntilExit(); exit(2)
        }
        func wait() { RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5)) }
        func bounds(_ id: UInt32) -> NSDictionary? {
            let raw = CGWindowListCopyWindowInfo([.optionIncludingWindow], id) as? [[String: Any]]
            return raw?.first?[kCGWindowBounds as String] as? NSDictionary
        }
        let beforeBounds = bounds(id)
        let appElement = AXUIElementCreateApplication(helper.processIdentifier)
        let accessible = attribute(appElement, kAXWindowsAttribute) as? [AXUIElement] ?? []
        let axResolved = accessible.contains { GWindowID($0) == id }
        let code = GMove(id, target.id)
        wait()
        let moved = (GWindowSpaces(id) ?? []).map(\.uint64Value) == [target.id]
        let fixed = (GWindowSpaces(fixedID) ?? []).map(\.uint64Value) == fixedOrigin
        let preserved = beforeBounds != nil && beforeBounds == bounds(id)
        _ = GMove(id, source.id)
        wait()
        let restored = (GWindowSpaces(id) ?? []).map(\.uint64Value) == origin
        helper.terminate(); helper.waitUntilExit()
        print("Cross-process AX window identified: \(axResolved)")
        print("Cross-process move confirmed: \(moved) (code \(code.rawValue))")
        print("Unselected window stayed: \(fixed)")
        print("Frame preserved: \(preserved)")
        print("Original desktop restored: \(restored)")
        exit(axResolved && moved && fixed && preserved && restored ? 0 : 1)
    }
}

if CommandLine.arguments.contains("--integration-test") {
    // Exercise only windows created by this test; never select or move user windows.
    MainActor.assumeIsolated {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let model = GeeseModel()
        guard let source = model.desktops.first(where: { $0.current }),
              let target = model.desktops.first(where: { $0.display == source.display && $0.id != source.id }) else {
            fputs("SKIP: need two regular desktops on one display\n", stderr)
            exit(2)
        }
        func wait() { RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.3)) }
        let test = NSWindow(contentRect: NSRect(x: 120, y: 140, width: 260, height: 120),
                            styleMask: [.titled], backing: .buffered, defer: false)
        test.title = "Geese movement test"
        test.styleMask.insert(.miniaturizable)
        let fixed = NSWindow(contentRect: NSRect(x: 160, y: 180, width: 260, height: 120),
                             styleMask: [.titled], backing: .buffered, defer: false)
        fixed.title = "Geese stationary test"
        test.isReleasedWhenClosed = false
        fixed.isReleasedWhenClosed = false
        test.orderFront(nil)
        fixed.orderFront(nil)
        wait()
        let testMinimized = CommandLine.arguments.contains("--minimized")
        if testMinimized { test.miniaturize(nil); wait(); wait() }
        let id = UInt32(test.windowNumber)
        let fixedID = UInt32(fixed.windowNumber)
        let origin = (GWindowSpaces(id) ?? []).map(\.uint64Value)
        let fixedOrigin = (GWindowSpaces(fixedID) ?? []).map(\.uint64Value)
        let frame = test.frame
        guard origin.count == 1 else {
            test.close(); fixed.close()
            fputs("FAIL: could not determine test window desktop\n", stderr); exit(1)
        }
        let error = GMove(id, target.id)
        wait()
        let after = (GWindowSpaces(id) ?? []).map(\.uint64Value)
        let fixedAfter = (GWindowSpaces(fixedID) ?? []).map(\.uint64Value)
        let framePreserved = test.frame == frame
        let restore = GMove(id, origin[0])
        wait()
        let restored = (GWindowSpaces(id) ?? []).map(\.uint64Value) == origin
        let minimizedPreserved = !testMinimized || test.isMiniaturized
        print("Minimized state preserved: \(minimizedPreserved)")
        test.close(); fixed.close()
        let passed = minimizedPreserved && after == [target.id] && fixedAfter == fixedOrigin && framePreserved && restored
        print("Move return code: \(error.rawValue); restore return code: \(restore.rawValue)")
        print("Moved to requested desktop: \(after == [target.id])")
        print("Other window stayed: \(fixedAfter == fixedOrigin)")
        print("Window position and size preserved: \(framePreserved)")
        print("Original desktop restored: \(restored)")
        exit(passed ? 0 : 1)
    }
}

if CommandLine.arguments.contains("--self-test") {
    func check(_ value: @autoclosure () -> Bool, _ label: String) {
        guard value() else { fputs("FAIL: \(label)\n", stderr); exit(1) }
        print("PASS: \(label)")
    }
    let userSpaces: Set<UInt64> = [1, 2, 3]
    check(MigrationRules.skipReason(minimized: false, fullscreen: false, spaces: [2], userSpaces: userSpaces) == nil, "regular window can move")
    check(MigrationRules.skipReason(minimized: true, fullscreen: false, spaces: [2], userSpaces: userSpaces) == nil, "minimized window can move")
    check(MigrationRules.skipReason(minimized: false, fullscreen: true, spaces: [9], userSpaces: userSpaces) != nil, "full-screen window skipped")
    check(MigrationRules.skipReason(minimized: false, fullscreen: false, spaces: [1, 2], userSpaces: userSpaces) != nil, "all-desktops window skipped")
    check(MigrationRules.skipReason(minimized: false, fullscreen: false, spaces: [], userSpaces: userSpaces) != nil, "unknown desktop skipped")
    check(MigrationRules.skipReason(minimized: false, fullscreen: false, spaces: [9], userSpaces: userSpaces) != nil, "non-user space skipped")
    let element = AXUIElementCreateSystemWide()
    let sample = [TravelWindow(id: 1, element: element, appID: "test", appName: "Test", title: "A", spaces: [1], skipReason: nil),
                  TravelWindow(id: 2, element: element, appID: "test", appName: "Test", title: "B", spaces: [2], skipReason: nil),
                  TravelWindow(id: 3, element: element, appID: "test", appName: "Test", title: "C", spaces: [2], skipReason: nil)]
    check(MigrationRules.distribution(sample) == [1: 1, 2: 2], "split flock counted by actual desktop")
    check(MigrationRules.distribution([]).isEmpty, "empty flock has no location")
    check(MigrationRules.flockDesktop(sample) == nil, "split flock has no disabled destination")
    check(MigrationRules.flockDesktop(Array(sample.suffix(2))) == 2, "only the flock's desktop is the current destination")
    check(MigrationRules.flockDesktop([]) == nil, "unknown flock does not disable a monitor's visible desktop")
    exit(0)
}

MainActor.assumeIsolated {
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
}
