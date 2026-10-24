import AppKit
import Carbon
import Combine

struct GeeseShortcut: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32
    var key: String

    static let standard = GeeseShortcut(keyCode: UInt32(kVK_ANSI_G),
        modifiers: UInt32(controlKey | optionKey | cmdKey), key: "G")

    var label: String {
        [(controlKey, "⌃"), (optionKey, "⌥"), (shiftKey, "⇧"), (cmdKey, "⌘")]
            .filter { modifiers & UInt32($0.0) != 0 }.map { $0.1 }.joined() + key
    }

    init(keyCode: UInt32, modifiers: UInt32, key: String) {
        self.keyCode = keyCode; self.modifiers = modifiers; self.key = key
    }

    init?(event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard !flags.intersection([.command, .control, .option]).isEmpty else { return nil }
        let names: [UInt16: String] = [36: "↩", 48: "⇥", 49: "Space", 51: "⌫", 53: "⎋",
            76: "⌤", 117: "⌦", 123: "←", 124: "→", 125: "↓", 126: "↑",
            115: "Home", 119: "End", 116: "Page Up", 121: "Page Down",
            122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6",
            98: "F7", 100: "F8", 101: "F9", 109: "F10", 103: "F11", 111: "F12"]
        let key = names[event.keyCode] ?? event.charactersIgnoringModifiers?.uppercased() ?? ""
        guard !key.isEmpty else { return nil }
        var modifiers: UInt32 = 0
        if flags.contains(.command) { modifiers |= UInt32(cmdKey) }
        if flags.contains(.control) { modifiers |= UInt32(controlKey) }
        if flags.contains(.option) { modifiers |= UInt32(optionKey) }
        if flags.contains(.shift) { modifiers |= UInt32(shiftKey) }
        self.init(keyCode: UInt32(event.keyCode), modifiers: modifiers, key: key)
    }
}

@MainActor
final class ShortcutPreferences: ObservableObject {
    @Published private(set) var shortcut: GeeseShortcut
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        shortcut = defaults.data(forKey: "globalShortcut")
            .flatMap { try? JSONDecoder().decode(GeeseShortcut.self, from: $0) } ?? .standard
    }
    func save(_ value: GeeseShortcut) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: "globalShortcut")
        shortcut = value
    }
}

final class ShortcutRecordButton: NSButton {
    var recording = false
    var onStart: (() -> Void)?
    override init(frame: NSRect) {
        super.init(frame: frame)
        bezelStyle = .rounded
        target = self
        action = #selector(startRecording)
        setAccessibilityLabel("Record keyboard shortcut")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func startRecording() {
        recording = true
        title = "Press shortcut…"
        onStart?()
    }
}
