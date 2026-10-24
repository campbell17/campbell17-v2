import AppKit

func require(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    if !condition() { throw NSError(domain: "GeeseOffDesktopTest", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
    print("PASS: \(message)")
}

if CommandLine.arguments.contains("--fixture") {
    let app = NSApplication.shared
    app.setActivationPolicy(.regular)
    let windows = (0..<3).map { index in
        let window = NSWindow(contentRect: NSRect(x: 120 + index * 30, y: 150, width: 240, height: 100),
                              styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "Geese off-desktop test \(index)"
        window.isReleasedWhenClosed = false
        window.orderFront(nil)
        return window
    }
    windows[2].miniaturize(nil)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
        print(windows.map { String($0.windowNumber) }.joined(separator: ",")); fflush(stdout)
    }
    app.run()
} else if CommandLine.arguments.contains("--cold-scan") {
    MainActor.assumeIsolated {
        _ = NSApplication.shared
        let model = GeeseModel()
        model.selected = ["local.tim.geese.off-desktop-fixture"]
        model.refresh()
        let space = UInt64(CommandLine.arguments.last!)!
        do {
            try require(model.traveling.count == 3 && model.flockDesktopID == space,
                        "fresh process discovers all off-desktop windows and their actual desktop")
            exit(0)
        } catch { print(error); exit(1) }
    }
} else {
    MainActor.assumeIsolated {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let model = GeeseModel()
        model.follow = false
        guard let source = model.desktops.first(where: { $0.current }),
              let distant = model.desktops.filter({ $0.display == source.display && $0.id != source.id })
                .max(by: { abs($0.index - source.index) < abs($1.index - source.index) }),
              let split = model.desktops.first(where: { $0.display == source.display && $0.id != source.id && $0.id != distant.id })
        else { print("Need at least three desktops"); exit(2) }
        func launch(_ name: String) throws -> (Process, [UInt32]) {
            let process = Process(), pipe = Pipe()
            let directory = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
            process.executableURL = directory.appendingPathComponent("\(name).app/Contents/MacOS/Fixture")
            process.arguments = ["--fixture"]; process.standardOutput = pipe
            try process.run()
            var line = Data()
            while let byte = try pipe.fileHandleForReading.read(upToCount: 1), !byte.isEmpty, byte.first != 10 { line.append(byte) }
            let ids = String(data: line, encoding: .utf8)?.split(separator: ",").compactMap { UInt32($0) } ?? []
            if ids.count != 3 { process.terminate(); throw NSError(domain: "Fixture", code: 1) }
            return (process, ids)
        }
        let selected: (Process, [UInt32]), unselected: (Process, [UInt32])
        do { selected = try launch("Selected"); unselected = try launch("Unselected") }
        catch { print(error); exit(1) }
        func memberships(_ id: UInt32) -> [UInt64] { (GWindowSpaces(id) ?? []).map(\.uint64Value) }
        Task { @MainActor in
            var success = false
            defer {
                selected.0.terminate(); selected.0.waitUntilExit()
                unselected.0.terminate(); unselected.0.waitUntilExit()
                exit(success ? 0 : 1)
            }
            func move(_ id: UInt32, to space: UInt64) async throws {
                _ = GMove(id, space)
                for _ in 0..<20 {
                    try await Task.sleep(for: .milliseconds(60))
                    if memberships(id) == [space] { return }
                }
                throw NSError(domain: "Fixture movement", code: 1)
            }
            do {
                try await move(selected.1[0], to: distant.id)
                try await move(selected.1[1], to: distant.id)
                try await move(selected.1[2], to: distant.id)
                try await move(unselected.1[0], to: distant.id)
                let cold = Process()
                cold.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
                cold.arguments = ["--cold-scan", String(distant.id)]
                try cold.run(); cold.waitUntilExit()
                try require(cold.terminationStatus == 0, "cold-start discovery succeeds without visiting the source desktop")
                model.selected = ["local.tim.geese.off-desktop-fixture"]
                model.refresh()
                try require(model.flockDesktopID == distant.id && model.traveling.count == 3,
                            "opening on another desktop preserves the flock location")
                let before = model.spaceChangeSerial
                await model.migrate(to: source)
                try require(model.issues.isEmpty && selected.1.allSatisfy { memberships($0) == [source.id] },
                            "bring-here moves all windows from the distant desktop")
                try require(model.flockDesktopID == source.id, "destination becomes the selected desktop")
                try await move(selected.1[0], to: distant.id)
                try await move(selected.1[1], to: split.id)
                try await move(selected.1[2], to: distant.id)
                model.refresh()
                try require(model.distribution.count == 2 && model.flockDesktopID == nil,
                            "windows split across desktops are all discovered")
                await model.migrate(to: source)
                try require(selected.1.allSatisfy { memberships($0) == [source.id] },
                            "one migration gathers windows from multiple desktops")
                if let otherDisplay = model.desktops.first(where: { $0.display != source.display }) {
                    try await move(selected.1[1], to: otherDisplay.id)
                    model.refresh()
                    try require(model.distribution[otherDisplay.id] == 1, "windows on the other monitor are discovered")
                    await model.migrate(to: source)
                    try require(memberships(selected.1[1]) == [source.id], "bring-here works across monitors")
                }
                let closeElement = model.traveling.first(where: { $0.id == selected.1[0] })!.element
                if let button = attribute(closeElement, kAXCloseButtonAttribute), CFGetTypeID(button) == AXUIElementGetTypeID() {
                    try require(AXUIElementPerformAction(button as! AXUIElement, kAXPressAction as CFString) == .success,
                                "fixture close action succeeds")
                    try await Task.sleep(for: .milliseconds(300))
                    model.refresh()
                    try require(!model.windows.contains(where: { $0.id == selected.1[0] }), "closed windows are removed from the discovery cache")
                }
                try require(memberships(unselected.1[0]) == [distant.id], "unselected app windows stay untouched")
                try require(memberships(selected.1[2]) == [source.id], "minimized windows move with the flock")
                let minimized = model.windows.first { $0.id == selected.1[2] }
                if let element = minimized?.element {
                    try require(attribute(element, kAXMinimizedAttribute) as? Bool == true, "moved window remains minimized")
                }
                try require(model.spaceChangeSerial == before, "bring-here never switches the user's desktop")
                success = true
            } catch { print("FAIL: \(error)") }
        }
        app.run()
    }
}
