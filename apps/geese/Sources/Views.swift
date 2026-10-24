import SwiftUI

enum GeeseTheme {
    static let accent = Color(nsColor: NSColor(name: nil) { appearance in
        if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            return NSColor(srgbRed: 0.74, green: 0.71, blue: 1, alpha: 1)
        }
        return NSColor(srgbRed: 27 / 255, green: 20 / 255, blue: 100 / 255, alpha: 1)
    })
    static let orange = Color(red: 247 / 255, green: 147 / 255, blue: 30 / 255)
    static let chromeColor = NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(srgbRed: 0.16, green: 0.14, blue: 0.23, alpha: 1)
            : NSColor(srgbRed: 243 / 255, green: 240 / 255, blue: 248 / 255, alpha: 1)
    }
    static let chrome = Color(nsColor: chromeColor)
    static let separator = accent.opacity(0.12)
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
        VStack(spacing: 0) {
            GeeseTheme.separator.frame(height: 1)
            content
            GeeseStatusView(model: model)
        }
        .frame(minWidth: 900, minHeight: 440)
        .background(Color(nsColor: .windowBackgroundColor))
        .tint(GeeseTheme.accent)
        .alert("Rename desktop", isPresented: Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })) {
            TextField("Name", text: $newName)
            Button("Save") { if let desktop = renaming { model.rename(desktop, newName) }; renaming = nil }
            Button("Cancel", role: .cancel) { renaming = nil }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
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
            }.padding(.horizontal, 24)
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(chosenApps) { app in
                        ChosenAppCard(app: app, reopen: { await model.reopen(app) }, remove: { model.select(app, false) })
                    }
                }.padding(.horizontal, 2).padding(.bottom, 2)
                    .background(CompactScrollIndicators().frame(width: 0, height: 0))
            }
            .contentMargins(.horizontal, 24, for: .scrollContent)
            .contentMargins(.trailing, 0, for: .scrollIndicators)
            .frame(minHeight: 80, maxHeight: .infinity).disabled(model.busy)
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
            }.fixedSize(horizontal: false, vertical: true).padding(.horizontal, 24)
        }
        .padding(.vertical, 24)
    }
}

struct GeeseTitleView: View {
    @ObservedObject var model: GeeseModel

    var body: some View {
        HStack(spacing: 7) {
            if let icon = model.iconStyle.image {
                Image(nsImage: icon).resizable().scaledToFit()
                    .frame(width: 23, height: 23).accessibilityHidden(true)
            }
            Text("Geese").font(.system(size: 16, weight: .semibold))
        }
        .foregroundStyle(GeeseTheme.accent)
        .frame(width: 132, height: 32)
        .accessibilityElement(children: .combine)
    }
}

private struct GeeseStatusView: View {
    @ObservedObject var model: GeeseModel
    @State private var showingSkipped = false

    private var desktop: Desktop? {
        model.desktops.first { $0.id == model.flockDesktopID }
    }
    private var skippedWindows: [TravelWindow] { model.windows.filter { $0.skipReason != nil } }
    private var skippedSummary: String {
        if skippedWindows.count == 1, let window = skippedWindows.first, let reason = window.skipReason {
            return "\(window.appName): \(reason.components(separatedBy: " — ").first ?? reason)"
        }
        return "\(skippedWindows.count) windows won’t move"
    }
    private var warning: String? {
        if !model.available { return "Window controls unavailable." }
        if !model.trusted { return "Allow Accessibility access to move apps." }
        if !model.issues.isEmpty { return model.issues.joined(separator: "\n") }
        return nil
    }
    private var status: String {
        if model.busy { return model.message }
        if let warning { return warning }
        if model.selected.isEmpty { return "Choose apps for your flock." }
        if model.traveling.isEmpty {
            return !skippedWindows.isEmpty ? "No movable windows."
                : "Open a window in your flock to get started."
        }
        if let desktop { return "Your flock is on \(model.name(desktop))." }
        return "Your flock is across \(model.distribution.count) desktops."
    }

    var body: some View {
        HStack(spacing: 8) {
            if model.busy {
                ProgressView().controlSize(.mini).frame(width: 10, height: 10)
            } else if warning != nil {
                Image(systemName: "exclamationmark.circle").foregroundStyle(.orange)
                    .accessibilityHidden(true)
            } else {
                Circle().fill(desktop != nil ? Color(red: 0.40, green: 0.64, blue: 0.47) : GeeseTheme.accent.opacity(0.45))
                    .frame(width: 6, height: 6).accessibilityHidden(true)
            }
            Text(status).font(.caption)
                .foregroundStyle(!model.busy && warning != nil ? Color.orange : GeeseTheme.accent.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true).textSelection(.enabled)
            Spacer(minLength: 16)
            if !model.busy && warning == nil {
                if !skippedWindows.isEmpty {
                    Button { showingSkipped.toggle() } label: {
                        Label(skippedSummary, systemImage: "info.circle")
                            .font(.caption).lineLimit(1).truncationMode(.middle)
                            .foregroundStyle(GeeseTheme.accent.opacity(0.7))
                    }
                    .buttonStyle(.plain).pointingCursor()
                    .help("Show which windows won’t move and why")
                    .popover(isPresented: $showingSkipped, arrowEdge: .top) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Windows not moving").font(.headline)
                            ScrollView {
                                VStack(alignment: .leading, spacing: 14) {
                                    ForEach(skippedWindows) { window in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(window.appName).font(.callout.weight(.semibold))
                                            Text(window.skipReason ?? "").font(.callout).foregroundStyle(.secondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }.frame(maxWidth: .infinity, alignment: .leading)
                            }.frame(maxHeight: min(280, CGFloat(skippedWindows.count) * 78))
                        }.padding(18).frame(width: 320)
                    }
                } else if desktop != nil {
                    Text("All together now.").font(.caption2)
                        .foregroundStyle(GeeseTheme.accent.opacity(0.45))
                }
            }
        }
        .padding(.horizontal, 24).padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
        .background(GeeseTheme.chrome)
        .overlay(alignment: .top) { GeeseTheme.separator.frame(height: 1) }
        .accessibilityElement(children: .contain)
    }
}

private struct CompactScrollIndicators: NSViewRepresentable {
    func makeNSView(context: Context) -> Configurator { Configurator() }
    func updateNSView(_ view: Configurator, context: Context) { view.configure() }

    final class Configurator: NSView {
        private weak var configuredScrollView: NSScrollView?
        private var styleObservation: NSKeyValueObservation?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            configure()
        }
        override func viewDidMoveToSuperview() {
            super.viewDidMoveToSuperview()
            configure()
        }
        func configure() {
            DispatchQueue.main.async { [weak self] in
                guard let self, let scrollView = enclosingScrollView else { return }
                if configuredScrollView !== scrollView {
                    configuredScrollView = scrollView
                    // SwiftUI reapplies the system style during layout updates.
                    styleObservation = scrollView.observe(\.scrollerStyle, options: [.new]) { [weak self] _, change in
                        if change.newValue != .overlay { self?.configure() }
                    }
                }
                if scrollView.scrollerStyle != .overlay { scrollView.scrollerStyle = .overlay }
                scrollView.verticalScroller?.controlSize = .small
                scrollView.drawsBackground = false
            }
        }
    }
}

struct GeeseSettingsView: View {
    @ObservedObject var model: GeeseModel
    @ObservedObject var updates: GeeseUpdates
    @ObservedObject var shortcuts: ShortcutPreferences
    var changeShortcut: () -> Void

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
            Button("Keyboard Shortcut… (\(shortcuts.shortcut.label))", action: changeShortcut)
            Button("Quit Geese") { NSApp.terminate(nil) }.keyboardShortcut("q")
        } label: {
            Image(systemName: "gearshape").font(.system(size: 16, weight: .regular)).frame(width: 28, height: 28)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .accessibilityLabel("Geese settings")
        .help("Settings")
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
    let reopen: () async -> Void
    @State private var opening = false
    let remove: () -> Void
    @State private var hovered = false
    @FocusState private var removeFocused: Bool
    var body: some View {
        VStack(spacing: 10) {
            if app.running == nil {
                Text("App closed").font(.caption).foregroundStyle(.secondary)
            } else {
                AppIcon(icon: app.icon, size: 36)
            }
            Text(app.name).fontWeight(.medium).lineLimit(2).multilineTextAlignment(.center)
            if app.running == nil {
                Button {
                    opening = true
                    Task {
                        await reopen()
                        opening = false
                    }
                } label: {
                    Text(opening ? "Opening…" : "Reopen")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 12).padding(.vertical, 4)
                        .background(GeeseTheme.accent.opacity(0.09), in: Capsule())
                }
                .buttonStyle(.plain).foregroundStyle(GeeseTheme.accent)
                .disabled(opening).pointingCursor(enabled: !opening)
                .accessibilityLabel("Reopen \(app.name)")
            }
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
