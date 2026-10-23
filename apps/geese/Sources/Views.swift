import SwiftUI

enum GeeseTheme {
    static let accent = Color(nsColor: NSColor(name: nil) { appearance in
        if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            return NSColor(srgbRed: 0.74, green: 0.71, blue: 1, alpha: 1)
        }
        return NSColor(srgbRed: 27 / 255, green: 20 / 255, blue: 100 / 255, alpha: 1)
    })
    static let orange = Color(red: 247 / 255, green: 147 / 255, blue: 30 / 255)
}

struct GeeseView: View {
    @ObservedObject var model: GeeseModel
    @State private var adding = false
    @State private var search = ""
    @State private var renaming: Desktop?
    @State private var newName = ""
    @State private var selectedDisplay: String?
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: 100, maximum: 150), spacing: 10),
              count: min(5, max(1, visibleDesktops.count)))
    }
    private var currentDisplay: String? {
        if let selectedDisplay, displays.contains(selectedDisplay) { return selectedDisplay }
        return model.desktops.first(where: { $0.id == model.flockDesktopID })?.display ?? displays.first
    }
    private var displays: [String] {
        model.desktops.reduce(into: []) { result, desktop in
            if !result.contains(desktop.display) { result.append(desktop.display) }
        }
    }
    private var visibleDesktops: [Desktop] {
        guard !displays.isEmpty else { return [] }
        return model.desktops.filter { $0.display == currentDisplay }
    }
    private var chosenApps: [RunningApp] { model.apps.filter { model.selected.contains($0.id) } }
    private var availableApps: [RunningApp] {
        model.apps.filter {
            !model.selected.contains($0.id) && $0.running != nil &&
            (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if !model.available {
                Label("Window controls unavailable", systemImage: "exclamationmark.triangle").foregroundStyle(.orange)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Fly these geese…").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .trailing) {
                Button {
                    model.refresh()
                    search = ""
                    adding.toggle()
                } label: { Image(systemName: "plus").frame(width: 28, height: 28) }
                .buttonStyle(.plain).accessibilityLabel("Add app").disabled(model.busy).pointingCursor(enabled: !model.busy)
                .popover(isPresented: $adding, arrowEdge: .leading) {
                    VStack(spacing: 12) {
                        TextField("Search apps", text: $search).textFieldStyle(.roundedBorder)
                        ScrollView {
                            LazyVStack(spacing: 3) {
                                ForEach(availableApps) { app in
                                    Button { model.select(app, true) } label: {
                                        HStack(spacing: 10) {
                                            AppIcon(icon: app.icon)
                                            Text(app.name).lineLimit(1)
                                            Spacer()
                                            Image(systemName: "plus").foregroundStyle(.secondary)
                                        }.padding(8).contentShape(Rectangle())
                                    }.buttonStyle(.plain).accessibilityLabel("Add \(app.name)").pointingCursor()
                                }
                                if availableApps.isEmpty { Text("No apps found").foregroundStyle(.secondary).padding() }
                            }
                        }.frame(height: 280)
                    }.padding(14).frame(width: 280)
                }
            }
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(chosenApps) { app in
                        ChosenAppCard(app: app) { model.select(app, false) }
                    }
                }.padding(.horizontal, 2).padding(.bottom, 2)
            }.frame(minHeight: 80, maxHeight: .infinity).disabled(model.busy)
            }

            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Displays:").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    ForEach(displays, id: \.self) { display in
                        Button { selectedDisplay = display } label: {
                            HStack(spacing: 9) {
                                Image(systemName: model.displayIsBuiltIn(display) ? "laptopcomputer" : "display")
                                    .font(.system(size: 20)).foregroundStyle(GeeseTheme.accent)
                                Text(model.displayName(display)).font(.caption.weight(.medium))
                                    .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                                Spacer(minLength: 0)
                            }
                            .padding(10).frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
                            .background(currentDisplay == display ? GeeseTheme.accent.opacity(0.09) : Color(nsColor: .controlBackgroundColor),
                                        in: RoundedRectangle(cornerRadius: 9))
                            .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(currentDisplay == display ? GeeseTheme.accent.opacity(0.6) : .secondary.opacity(0.15)))
                            .contentShape(RoundedRectangle(cornerRadius: 9))
                        }
                        .buttonStyle(.plain).disabled(model.busy).pointingCursor(enabled: !model.busy)
                        .accessibilityLabel("Show desktops on \(model.displayName(display))")
                        .accessibilityAddTraits(currentDisplay == display ? .isSelected : [])
                    }
                }.frame(width: 144)
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    Text("To this pond:").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                ForEach(visibleDesktops) { desktop in
                    Button {
                        Task {
                            await model.migrate(to: desktop)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "desktopcomputer")
                                Spacer()
                                if model.distribution[desktop.id, default: 0] > 0 {
                                    Image("GeeseMenu").renderingMode(.template).resizable().scaledToFit()
                                        .frame(width: 23, height: 13).foregroundStyle(GeeseTheme.orange)
                                }
                            }.foregroundStyle(GeeseTheme.accent)
                            Text(model.name(desktop)).font(.callout.weight(.semibold)).lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading).padding(15)
                        .background(model.flockDesktopID == desktop.id ? GeeseTheme.accent.opacity(0.09) : Color(nsColor: .controlBackgroundColor),
                                    in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(model.flockDesktopID == desktop.id ? GeeseTheme.accent.opacity(0.6) : .secondary.opacity(0.15)))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain).disabled(model.busy || !model.available || model.flockDesktopID == desktop.id)
                    .pointingCursor(enabled: !model.busy && model.available && model.flockDesktopID != desktop.id)
                    .accessibilityLabel("Move apps to \(model.name(desktop))")
                    .accessibilityValue("\(model.flockDesktopID == desktop.id ? "Apps are already here. " : "")\(model.distribution[desktop.id, default: 0]) selected windows")
                    .contextMenu {
                        Button("Rename…") { newName = model.name(desktop); renaming = desktop }
                    }
                }
            }
            .frame(maxWidth: CGFloat(columns.count) * 150 + CGFloat(columns.count - 1) * 10, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            if model.desktops.isEmpty { Text("No desktops found").foregroundStyle(.secondary) }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }.fixedSize(horizontal: false, vertical: true)

            if model.busy {
                HStack { ProgressView().controlSize(.small); Text(model.message).font(.callout).foregroundStyle(.secondary) }
            } else if !model.issues.isEmpty {
                Text(model.issues.joined(separator: "\n")).font(.callout).foregroundStyle(.orange).textSelection(.enabled)
            } else if model.hasSkippedWindows {
                Text(model.message).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(24).frame(minWidth: 900, minHeight: 440)
        .background(Color(nsColor: .windowBackgroundColor))
        .tint(GeeseTheme.accent)
        .alert("Rename desktop", isPresented: Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })) {
            TextField("Name", text: $newName)
            Button("Save") { if let desktop = renaming { model.rename(desktop, newName) }; renaming = nil }
            Button("Cancel", role: .cancel) { renaming = nil }
        }
    }
}

struct GeeseSettingsView: View {
    @ObservedObject var model: GeeseModel
    @ObservedObject var updates: GeeseUpdates

    var body: some View {
        Menu {
            Toggle("Pin window", isOn: $model.pinned)
            Toggle("Follow windows", isOn: $model.follow)
            Button("Refresh") { model.refresh() }
            Button("Accessibility Settings…") { model.requestAccess() }
            Picker("App icon", selection: $model.iconStyle) {
                ForEach(GeeseIconStyle.allCases) { style in
                    HStack {
                        if let image = style.menuImage { Image(nsImage: image) }
                        Text(style.title)
                    }.tag(style)
                }
            }
            Button("Check for Updates…") { updates.check() }.disabled(!updates.canCheck)
            Divider()
            Text(GeeseUpdates.versionDescription)
            Text("⌃⌥⌘G")
            Button("Quit Geese") { NSApp.terminate(nil) }.keyboardShortcut("q")
        } label: {
            Image(systemName: "gearshape").font(.system(size: 15)).frame(width: 28, height: 24)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .accessibilityLabel("Geese settings")
        .tint(GeeseTheme.accent)
        .pointingCursor()
    }
}

private struct AppIcon: View {
    let icon: NSImage?
    var size: CGFloat = 28
    var body: some View {
        if let icon { Image(nsImage: icon).resizable().frame(width: size, height: size).accessibilityHidden(true) }
        else { Image(systemName: "app.dashed").frame(width: size, height: size).foregroundStyle(.secondary).accessibilityHidden(true) }
    }
}

private struct ChosenAppCard: View {
    let app: RunningApp
    let remove: () -> Void
    @State private var hovered = false
    @FocusState private var removeFocused: Bool
    var body: some View {
        VStack(spacing: 10) {
            AppIcon(icon: app.icon, size: 36)
            Text(app.name).fontWeight(.medium).lineLimit(2).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 96)
        .padding(12)
        .background(hovered ? GeeseTheme.accent.opacity(0.04) : Color(nsColor: .controlBackgroundColor),
                    in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.secondary.opacity(0.18)))
        .overlay(alignment: .topTrailing) {
            Button(action: remove) {
                Image(systemName: "xmark").font(.system(size: 11, weight: .semibold))
                    .frame(width: 28, height: 28).contentShape(Rectangle())
            }
            .buttonStyle(.plain).focused($removeFocused)
            .foregroundStyle(hovered || removeFocused ? Color.secondary : Color.clear)
            .accessibilityLabel("Remove \(app.name)")
            .pointingCursor()
            .padding(5)
        }
        .overlay(alignment: .bottomLeading) {
            if app.running == nil {
                Image(systemName: "moon").font(.caption).foregroundStyle(.secondary)
                    .accessibilityLabel("Not running").padding(10)
            }
        }
        .accessibilityElement(children: .contain)
        .onHover { hovered = $0 }
        .contextMenu { Button("Remove \(app.name)", action: remove) }
    }
}

private struct PointingCursor: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    let enabled: Bool
    @State private var cursorPushed = false

    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                if hovering && enabled && isEnabled {
                    if !cursorPushed { NSCursor.pointingHand.push(); cursorPushed = true }
                } else { restoreCursor() }
            }
            .onChange(of: enabled) { _, value in if !value { restoreCursor() } }
            .onChange(of: isEnabled) { _, value in if !value { restoreCursor() } }
            .onDisappear { restoreCursor() }
    }

    private func restoreCursor() {
        if cursorPushed { NSCursor.pop(); cursorPushed = false }
    }
}

private extension View {
    func pointingCursor(enabled: Bool = true) -> some View {
        modifier(PointingCursor(enabled: enabled))
    }
}
