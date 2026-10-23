import AppKit
import SwiftUI

func attribute(_ element: AXUIElement?, _ key: String) -> CFTypeRef? {
    guard let element else { return nil }
    var value: CFTypeRef?
    return AXUIElementCopyAttributeValue(element, key as CFString, &value) == .success ? value : nil
}

enum GeeseIconStyle: String, CaseIterable, Identifiable {
    case dark, light
    var id: String { rawValue }
    var title: String { self == .dark ? "Dark" : "Light" }
    var resourceName: String { self == .dark ? "Geese" : "GeeseLight" }
    var image: NSImage? {
        Bundle.main.url(forResource: resourceName, withExtension: "icns").flatMap { NSImage(contentsOf: $0) }
    }
    var menuImage: NSImage? {
        guard let artwork = image else { return nil }
        return NSImage(size: NSSize(width: 20, height: 20), flipped: false) { rect in
            artwork.draw(in: rect)
            return true
        }
    }
}

struct Desktop: Identifiable {
    let id: UInt64
    let uuid: String
    let display: String
    let displayID: UInt32
    let index: Int
    let missionIndex: Int
    let current: Bool
    var key: String { "\(display)/\(uuid)" }
}

struct TravelWindow: Identifiable {
    let id: UInt32
    let element: AXUIElement?
    let appID: String
    let appName: String
    let title: String
    let spaces: [UInt64]
    let skipReason: String?
    var ownerPID: pid_t? = nil
}

struct RunningApp: Identifiable {
    let id: String
    let name: String
    let icon: NSImage?
    let running: NSRunningApplication?
}

enum MigrationRules {
    static func skipReason(minimized: Bool, fullscreen: Bool, spaces: [UInt64], userSpaces: Set<UInt64>) -> String? {
        if fullscreen { return "Full screen — leave full screen to move" }
        if minimized { return "Minimized — restore to move" }
        if spaces.count > 1 { return "On multiple desktops — set Assign To to None" }
        if spaces.isEmpty { return "Desktop unavailable" }
        if !spaces.allSatisfy(userSpaces.contains) { return "Not on a regular desktop" }
        return nil
    }
    static func flockDesktop(_ windows: [TravelWindow]) -> UInt64? {
        let counts = distribution(windows)
        return counts.count == 1 ? counts.keys.first : nil
    }

    static func distribution(_ windows: [TravelWindow]) -> [UInt64: Int] {
        var result: [UInt64: Int] = [:]
        for window in windows {
            for space in window.spaces { result[space, default: 0] += 1 }
        }
        return result
    }
}

@MainActor
final class GeeseModel: ObservableObject {
    @Published var desktops: [Desktop] = []
    @Published var apps: [RunningApp] = []
    @Published var windows: [TravelWindow] = []
    @Published var selected: Set<String>
    @Published var trusted = AXIsProcessTrusted()
    @Published var busy = false
    @Published var message = ""
    @Published var hasSkippedWindows = false
    @Published var issues: [String] = []
    @Published var aliases: [String: String]
    @Published var follow: Bool { didSet { defaults.set(follow, forKey: "follow") } }
    @Published var iconStyle: GeeseIconStyle {
        didSet {
            defaults.set(iconStyle.rawValue, forKey: "iconStyle")
            onIconChanged?(iconStyle)
        }
    }
    @Published var pinned: Bool {
        didSet {
            defaults.set(pinned, forKey: "pinned")
            onPinChanged?(pinned)
        }
    }
    var onIconChanged: ((GeeseIconStyle) -> Void)?
    var onPinChanged: ((Bool) -> Void)?
    var onMigrationFinished: (() -> Void)?
    private let defaults = UserDefaults.standard
    private var knownNames: [String: String]
    private var timer: Timer?
    var available: Bool { GAvailable() }
    private(set) var spaceChangeSerial = 0
    var traveling: [TravelWindow] { windows.filter { $0.skipReason == nil } }
    var distribution: [UInt64: Int] { MigrationRules.distribution(traveling) }
    var flockDesktopID: UInt64? { MigrationRules.flockDesktop(traveling) }

    init() {
        selected = Set(defaults.stringArray(forKey: "selected") ?? [])
        knownNames = defaults.dictionary(forKey: "appNames") as? [String: String] ?? [:]
        aliases = defaults.dictionary(forKey: "aliases") as? [String: String] ?? [:]
        follow = defaults.object(forKey: "follow") as? Bool ?? true
        pinned = defaults.bool(forKey: "pinned")
        iconStyle = GeeseIconStyle(rawValue: defaults.string(forKey: "iconStyle") ?? "") ?? .dark
        _ = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification,
                                                         object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.spaceChangeSerial += 1 }
        }
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, !self.busy, NSApp.windows.contains(where: { $0.isVisible }) else { return }
                self.refresh()
            }
        }
    }

    func name(_ desktop: Desktop) -> String {
        let custom = aliases[desktop.key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return custom.isEmpty ? "Desktop \(desktop.index)" : custom
    }

    func rename(_ desktop: Desktop, _ name: String) {
        aliases[desktop.key] = name
        defaults.set(aliases, forKey: "aliases")
    }

    func select(_ app: RunningApp, _ value: Bool) {
        issues = []
        message = ""
        hasSkippedWindows = false
        if value { selected.insert(app.id); knownNames[app.id] = app.name }
        else { selected.remove(app.id) }
        defaults.set(Array(selected), forKey: "selected")
        defaults.set(knownNames, forKey: "appNames")
        refresh()
    }

    func requestAccess() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }

    private func screen(for display: String) -> NSScreen? {
        guard let id = desktops.first(where: { $0.display == display })?.displayID else { return nil }
        return NSScreen.screens.first {
            ($0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value == id
        }
    }

    func displayName(_ display: String) -> String {
        screen(for: display)?.localizedName ?? "Unknown display"
    }

    func displayIsBuiltIn(_ display: String) -> Bool {
        guard let id = desktops.first(where: { $0.display == display })?.displayID else { return false }
        return CGDisplayIsBuiltin(id) != 0
    }

    func readDesktops() -> [Desktop] {
        let raw = GDisplays() as? [[String: Any]] ?? []
        var result: [Desktop] = []
        var ordinal = 0
        for item in raw {
            let identifier = item["Display Identifier"] as? String ?? "Main"
            let current = (item["Current Space"] as? [String: Any])?["ManagedSpaceID"] as? NSNumber
            let screen = NSScreen.screens.first { screen in
                guard let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber,
                      let uuid = CGDisplayCreateUUIDFromDisplayID(number.uint32Value)?.takeRetainedValue() else { return false }
                return CFUUIDCreateString(nil, uuid) as String == identifier
            } ?? (raw.count == 1 ? NSScreen.screens.first : nil)
            let displayID = (screen?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value ?? 0
            let spaces = item["Spaces"] as? [[String: Any]] ?? []
            for (index, space) in spaces.enumerated() {
                guard (space["type"] as? NSNumber)?.intValue == 0,
                      let id = space["ManagedSpaceID"] as? NSNumber else { continue }
                ordinal += 1
                result.append(Desktop(id: id.uint64Value,
                                      uuid: space["uuid"] as? String ?? String(id.uint64Value),
                                      display: identifier, displayID: displayID,
                                      index: ordinal, missionIndex: index,
                                      current: current?.uint64Value == id.uint64Value))
            }
        }
        return result
    }

    func refresh() {
        guard !busy else { return }
        trusted = AXIsProcessTrusted()
        desktops = readDesktops()
        let running = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular && $0.bundleIdentifier != Bundle.main.bundleIdentifier && $0.bundleIdentifier != nil
        }
        var seen: Set<String> = []
        apps = running.compactMap { app in
            guard let id = app.bundleIdentifier, seen.insert(id).inserted else { return nil }
            return RunningApp(id: id, name: app.localizedName ?? id, icon: app.icon, running: app)
        }
        if defaults.object(forKey: "selected") == nil {
            let suggestions = ["slack", "granola", "chatgpt", "toggl", "toggle", "roam", "hey", "messages", "signal"]
            for app in apps where suggestions.contains(where: { app.name.lowercased().contains($0) }) {
                selected.insert(app.id)
                knownNames[app.id] = app.name
            }
            defaults.set(Array(selected), forKey: "selected")
            defaults.set(knownNames, forKey: "appNames")
        }
        for id in selected where !seen.contains(id) {
            apps.append(RunningApp(id: id, name: knownNames[id] ?? id, icon: nil, running: nil))
        }
        apps.sort { lhs, rhs in
            if selected.contains(lhs.id) != selected.contains(rhs.id) { return selected.contains(lhs.id) }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
        windows = trusted ? scanWindows() : []
    }

    private func scanWindows() -> [TravelWindow] {
        let userSpaces = Set(desktops.map(\.id))
        var result: [TravelWindow] = []
        let inventory = GWindowInventory() as? [[String: Any]] ?? []
        var seen: Set<UInt32> = []
        for app in NSWorkspace.shared.runningApplications {
            guard let id = app.bundleIdentifier, selected.contains(id) else { continue }
            let elements = GApplicationWindows(app.processIdentifier) as? [AXUIElement] ?? []
            for window in elements {
                let subrole = attribute(window, kAXSubroleAttribute) as? String ?? ""
                guard subrole == kAXStandardWindowSubrole || subrole == kAXDialogSubrole else { continue }
                let windowID = GWindowID(window)
                guard windowID != 0, seen.insert(windowID).inserted else { continue }
                let memberships = (GWindowSpaces(windowID) ?? []).map(\.uint64Value)
                let minimized = attribute(window, kAXMinimizedAttribute) as? Bool ?? false
                let fullscreen = attribute(window, "AXFullScreen") as? Bool ?? false
                result.append(TravelWindow(id: windowID, element: window, appID: id,
                                           appName: app.localizedName ?? id,
                                           title: attribute(window, kAXTitleAttribute) as? String ?? "Window",
                                           spaces: memberships,
                                           skipReason: MigrationRules.skipReason(minimized: minimized, fullscreen: fullscreen,
                                                                                spaces: memberships, userSpaces: userSpaces)))
            }
            for entry in inventory where (entry["pid"] as? NSNumber)?.int32Value == app.processIdentifier {
                guard let windowID = (entry["id"] as? NSNumber)?.uint32Value, seen.insert(windowID).inserted else { continue }
                let memberships = (GWindowSpaces(windowID) ?? []).map(\.uint64Value)
                let minimized = entry["minimized"] as? Bool ?? true
                result.append(TravelWindow(id: windowID, element: nil, appID: id,
                                          appName: app.localizedName ?? id, title: "Window", spaces: memberships,
                                          skipReason: MigrationRules.skipReason(minimized: minimized, fullscreen: false,
                                                                               spaces: memberships, userSpaces: userSpaces),
                                          ownerPID: app.processIdentifier))
            }
        }
        return result
    }

    private func windowIsMovable(_ window: TravelWindow) -> Bool {
        if let element = window.element {
            return GWindowID(element) == window.id &&
                (attribute(element, kAXMinimizedAttribute) as? Bool) == false &&
                (attribute(element, "AXFullScreen") as? Bool ?? false) == false
        }
        guard let pid = window.ownerPID,
              NSRunningApplication(processIdentifier: pid)?.bundleIdentifier == window.appID else { return false }
        return (GWindowInventory() as? [[String: Any]] ?? []).contains {
            ($0["id"] as? NSNumber)?.uint32Value == window.id &&
            ($0["pid"] as? NSNumber)?.int32Value == pid && ($0["minimized"] as? Bool) == false
        }
    }

    func migrate(to target: Desktop) async {
        guard !busy else { return }
        refresh()
        issues = []
        hasSkippedWindows = false
        guard trusted, available else { issues = ["Allow Accessibility access to move apps."]; return }
        guard desktops.contains(where: { $0.id == target.id }) else { issues = ["That desktop is no longer available."]; return }
        guard flockDesktopID != target.id else { return }
        let candidates = traveling
        guard !candidates.isEmpty else { issues = ["No movable windows. Add an app or restore its windows."]; return }
        busy = true
        issues = []
        defer { busy = false; refresh(); onMigrationFinished?() }
        var moved = 0
        var already = 0
        var failed = 0
        var landingWindow: TravelWindow?
        for (index, window) in candidates.enumerated() {
            message = "Moving \(index + 1) of \(candidates.count)…"
            let before = (GWindowSpaces(window.id) ?? []).map(\.uint64Value)
            if before == [target.id] { already += 1; landingWindow = window; continue }
            guard before.count == 1, desktops.contains(where: { $0.id == before[0] }) else {
                failed += 1
                issues.append("\(window.appName): desktop changed; skipped.")
                continue
            }
            // Recheck identity, minimized, and full screen state immediately before each move.
            guard windowIsMovable(window) else {
                failed += 1
                issues.append("\(window.appName): window changed; skipped.")
                continue
            }
            let error = GMove(window.id, target.id)
            var verified = false
            for _ in 0..<12 {
                try? await Task.sleep(for: .milliseconds(60))
                let actual = (GWindowSpaces(window.id) ?? []).map(\.uint64Value)
                if actual == [target.id] { verified = true; break }
            }
            if verified { moved += 1; landingWindow = window }
            else {
                failed += 1
                issues.append("\(window.appName): could not move (\(error.rawValue)).")
            }
        }
        let skipped = windows.filter { $0.skipReason != nil }.count
        hasSkippedWindows = skipped > 0
        message = "\(moved) moved · \(already) already there"
        if skipped > 0 { message += " · \(skipped) skipped" }
        if failed > 0 { message += " · \(failed) failed" }
        if follow && moved + already > 0 {
            let switched = await switchDesktop(target, activating: landingWindow)
            if !switched { issues.append("Apps moved. Could not switch desktops; check Mission Control shortcuts.") }
        }
    }

    // Use Mission Control's real transition, never the bookkeeping-only SkyLight setter.
    // A changed space ID alone is insufficient: require the native workspace notification too.
    func switchDesktop(_ target: Desktop, activating window: TravelWindow? = nil) async -> Bool {
        guard AXIsProcessTrusted(), target.displayID != 0 else { return false }
        let pointer = CGEvent(source: nil)?.location
        let bounds = CGDisplayBounds(target.displayID)
        let warped = pointer.map { !bounds.contains($0) } ?? false
        if warped { CGWarpMouseCursorPosition(CGPoint(x: bounds.midX, y: bounds.midY)) }
        defer { if warped, let pointer { CGWarpMouseCursorPosition(pointer) } }

        if let initial = route(to: target), initial.current == initial.target { return true }
        if let window, await jumpDirectly(to: target, activating: window) { return true }

        for _ in 0..<32 {
            guard let initial = route(to: target) else { return false }
            if initial.current == initial.target { return true }
            let serial = spaceChangeSerial
            guard GPostDesktopStep(initial.target > initial.current) else { return false }
            var transitioned = false
            for _ in 0..<30 {
                try? await Task.sleep(for: .milliseconds(100))
                guard let updated = route(to: target) else { return false }
                if spaceChangeSerial > serial && updated.current != initial.current {
                    transitioned = true
                    break
                }
            }
            guard transitioned else { return false }
            // Let the native slide complete before sending another arrow.
            try? await Task.sleep(for: .milliseconds(350))
        }
        return false
    }

    private func jumpDirectly(to target: Desktop, activating window: TravelWindow) async -> Bool {
        // Let Dock perform its normal switch to an app's window, without changing system preferences.
        guard UserDefaults(suiteName: "com.apple.dock")?.object(forKey: "workspaces-auto-swoosh") as? Bool != false,
              windowIsMovable(window),
              (GWindowSpaces(window.id) ?? []).map(\.uint64Value) == [target.id] else { return false }
        var pid: pid_t = window.ownerPID ?? 0
        if let element = window.element, AXUIElementGetPid(element, &pid) != .success { return false }
        guard let app = NSRunningApplication(processIdentifier: pid) else { return false }
        let serial = spaceChangeSerial
        if let element = window.element {
            _ = AXUIElementSetAttributeValue(element, kAXMainAttribute as CFString, kCFBooleanTrue)
            _ = AXUIElementPerformAction(element, kAXRaiseAction as CFString)
        }
        guard app.activate(options: []) else { return false }
        for _ in 0..<25 {
            try? await Task.sleep(for: .milliseconds(100))
            guard let updated = route(to: target) else { return false }
            if spaceChangeSerial > serial && updated.current == updated.target {
                try? await Task.sleep(for: .milliseconds(350))
                return true
            }
        }
        return false
    }

    private func route(to target: Desktop) -> (current: Int, target: Int)? {
        let displays = GDisplays() as? [[String: Any]] ?? []
        guard let display = displays.first(where: { $0["Display Identifier"] as? String == target.display }),
              let current = (display["Current Space"] as? [String: Any])?["ManagedSpaceID"] as? NSNumber,
              let spaces = display["Spaces"] as? [[String: Any]] else { return nil }
        let ids = spaces.compactMap { ($0["ManagedSpaceID"] as? NSNumber)?.uint64Value }
        guard let from = ids.firstIndex(of: current.uint64Value), let to = ids.firstIndex(of: target.id) else { return nil }
        return (from, to)
    }
}
