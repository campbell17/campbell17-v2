import AppKit
import Carbon

func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else { fatalError(message) }
    print("PASS: \(message)")
}
func event(_ flags: NSEvent.ModifierFlags, code: UInt16 = 40, characters: String = "k") -> NSEvent {
    NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: flags, timestamp: 0,
                    windowNumber: 0, context: nil, characters: characters,
                    charactersIgnoringModifiers: characters, isARepeat: false, keyCode: code)!
}
MainActor.assumeIsolated {
    let suite = "GeeseShortcutTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let preferences = ShortcutPreferences(defaults: defaults)
    check(preferences.shortcut == .standard, "fresh install keeps existing default")
    check(GeeseShortcut(event: event([])) == nil, "plain typing is not accepted")
    check(GeeseShortcut(event: event(.shift)) == nil, "shift-only typing is not accepted")
    let custom = GeeseShortcut(event: event([.command, .shift]))!
    check(custom.label == "⇧⌘K", "recorded combination has readable label")
    check(custom.modifiers == UInt32(cmdKey | shiftKey), "recorded modifiers match Carbon registration")
    preferences.save(custom)
    check(ShortcutPreferences(defaults: defaults).shortcut == custom, "custom shortcut survives preferences reload")
    preferences.save(.standard)
    check(ShortcutPreferences(defaults: defaults).shortcut == .standard, "reset persists default")
    defaults.set(Data("invalid".utf8), forKey: "globalShortcut")
    check(ShortcutPreferences(defaults: defaults).shortcut == .standard, "invalid stored value falls back safely")
}
