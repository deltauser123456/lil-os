import SwiftUI

private enum OSApp: String, CaseIterable, Identifiable {
    case files = "Files"
    case notes = "Notepad"
    case calculator = "Calculator"
    case settings = "Settings"
    case about = "About Lil-OS"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .files: return "folder.fill"
        case .notes: return "note.text"
        case .calculator: return "calculator.fill"
        case .settings: return "gearshape.fill"
        case .about: return "desktopcomputer"
        }
    }
    var tint: Color {
        switch self {
        case .files: return .cyan
        case .notes: return .yellow
        case .calculator: return .orange
        case .settings: return .gray
        case .about: return .purple
        }
    }
}

struct DesktopView: View {
    @State private var openApp: OSApp? = nil
    @State private var isLocked = true
    @State private var showLauncher = false
    @State private var noteText = "Welcome to Lil-OS!\n\nYour own little desktop, right on your iPhone."
    @State private var noteFileURL: URL? = nil
    @State private var fileURLs: [URL] = []
    @State private var showNewFilePrompt = false
    @State private var newFileName = "Untitled"
    @State private var saveStatus = "Ready"
    @State private var darkMode = true
    @State private var wallpaper = 0
    @State private var calculatorDisplay = "0"
    @State private var calculatorStored: Double? = nil
    @State private var calculatorOperation: String? = nil
    @State private var calculatorFresh = true
    @State private var windowOffset = CGSize.zero
    @State private var windowDragOrigin = CGSize.zero
    @State private var isMinimized = false
    @State private var isMaximized = false
    @State private var clock = Date()

    private let wallpapers: [[Color]] = [
        [Color(red: 0.03, green: 0.08, blue: 0.22), Color(red: 0.10, green: 0.32, blue: 0.55), Color(red: 0.34, green: 0.12, blue: 0.48)],
        [Color(red: 0.06, green: 0.18, blue: 0.16), Color(red: 0.05, green: 0.42, blue: 0.38), Color(red: 0.20, green: 0.12, blue: 0.32)],
        [Color(red: 0.20, green: 0.08, blue: 0.20), Color(red: 0.48, green: 0.15, blue: 0.28), Color(red: 0.10, green: 0.10, blue: 0.25)]
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                wallpaperView
                VStack(spacing: 0) {
                    menuBar
                    HStack(alignment: .top, spacing: 14) {
                        VStack(alignment: .leading, spacing: 18) {
                            desktopIcon(.files)
                            desktopIcon(.notes)
                            desktopIcon(.calculator)
                            desktopIcon(.settings)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 22)
                    Spacer()
                    dock
                }
                if showLauncher {
                    launcher
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(5)
                }
                if let app = openApp, !isMinimized {
                    appWindow(app, screen: geo.size)
                        .zIndex(3)
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                }
                if isLocked {
                    LockScreenView(date: clock) {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isLocked = false
                        }
                    }
                    .zIndex(10)
                    .transition(.opacity)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
            .animation(.spring(response: 0.34, dampingFraction: 0.86), value: openApp)
            .animation(.spring(response: 0.3, dampingFraction: 0.85), value: showLauncher)
            .animation(.spring(response: 0.32, dampingFraction: 0.86), value: isMinimized)
            .animation(.spring(response: 0.32, dampingFraction: 0.86), value: isMaximized)
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { date in clock = date }
        }
        .ignoresSafeArea()
        .statusBarHidden()
    }

    private var wallpaperView: some View {
        ZStack {
            LinearGradient(colors: wallpapers[wallpaper], startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 330, height: 330)
                .blur(radius: 2)
                .offset(x: 145, y: -185)
            Circle()
                .fill(.cyan.opacity(0.15))
                .frame(width: 260, height: 260)
                .blur(radius: 36)
                .offset(x: -140, y: 180)
            Rectangle().fill(.black.opacity(0.12))
        }
        .ignoresSafeArea()
    }

    private var menuBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "apple.terminal.fill")
                .font(.system(size: 15, weight: .bold))
            Text("Lil-OS").font(.system(size: 14, weight: .bold))
            Text(isMinimized ? "Desktop" : (openApp?.rawValue ?? "Desktop"))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.68))
            Spacer()
            Image(systemName: "wifi")
            Image(systemName: "battery.100percent")
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLocked = true
                }
            } label: {
                Image(systemName: "lock.open")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Lock Lil-OS")
            Text(clock.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 12, weight: .semibold).monospacedDigit())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(.ultraThinMaterial.opacity(0.72))
        .overlay(alignment: .bottom) { Rectangle().fill(.white.opacity(0.12)).frame(height: 0.5) }
    }

    private func desktopIcon(_ app: OSApp) -> some View {
        Button { launch(app) } label: {
            VStack(spacing: 5) {
                Image(systemName: app.symbol)
                    .font(.system(size: 27, weight: .medium))
                    .foregroundStyle(app.tint)
                    .frame(width: 55, height: 48)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 13))
                    .overlay(RoundedRectangle(cornerRadius: 13).stroke(.white.opacity(0.16), lineWidth: 1))
                Text(app.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.7), radius: 3, y: 1)
            }
            .frame(width: 65)
        }
        .buttonStyle(.plain)
    }

    private var dock: some View {
        HStack(spacing: 13) {
            Button { withAnimation { showLauncher.toggle() } } label: {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(.white.opacity(0.17), in: RoundedRectangle(cornerRadius: 14))
            }
            Rectangle().fill(.white.opacity(0.2)).frame(width: 1, height: 32)
            ForEach([OSApp.files, .notes, .calculator, .settings], id: \.self) { app in
                Button { launch(app) } label: {
                    Image(systemName: app.symbol)
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(app.tint)
                        .frame(width: 43, height: 43)
                        .background(.white.opacity(0.13), in: RoundedRectangle(cornerRadius: 13))
                        .overlay(alignment: .bottom) {
                            Circle()
                                .fill(.white)
                                .frame(width: 4, height: 4)
                                .offset(y: 5)
                                .opacity(openApp == app ? 1 : 0)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.2), lineWidth: 1))
        .shadow(color: .black.opacity(0.3), radius: 18, y: 8)
        .padding(.bottom, 27)
    }

    private var launcher: some View {
        LauncherPanel(
            apps: OSApp.allCases,
            onLaunch: { app in launch(app) },
            onLock: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showLauncher = false
                    isLocked = true
                }
            }
        )
    }

    private func appWindow(_ app: OSApp, screen: CGSize) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        openApp = nil
                        isMinimized = false
                        isMaximized = false
                        windowOffset = .zero
                        windowDragOrigin = .zero
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(Color(red: 1, green: 0.36, blue: 0.34), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close window")

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isMinimized = true
                        isMaximized = false
                        windowOffset = .zero
                        windowDragOrigin = .zero
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(.black.opacity(0.75))
                        .frame(width: 22, height: 22)
                        .background(Color(red: 1, green: 0.73, blue: 0.25), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Minimize window")

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isMaximized.toggle()
                        windowOffset = .zero
                        windowDragOrigin = .zero
                    }
                } label: {
                    Image(systemName: isMaximized ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(.black.opacity(0.75))
                        .frame(width: 22, height: 22)
                        .background(Color(red: 0.28, green: 0.82, blue: 0.48), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isMaximized ? "Restore window size" : "Maximize window")
                Spacer()
                Text(app.rawValue).font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Image(systemName: app.symbol).foregroundStyle(app.tint)
            }
            .padding(.horizontal, 14)
            .frame(height: 43)
            .background(Color(red: 0.12, green: 0.14, blue: 0.20))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { value in
                        guard !isMaximized else { return }
                        windowOffset = CGSize(
                            width: windowDragOrigin.width + value.translation.width,
                            height: windowDragOrigin.height + value.translation.height
                        )
                    }
                    .onEnded { _ in
                        guard !isMaximized else { return }
                        windowDragOrigin = windowOffset
                    }
            )
            Group {
                switch app {
                case .files: filesContent
                case .notes: notesContent
                case .calculator: calculatorContent
                case .settings: settingsContent
                case .about: aboutContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.10, green: 0.12, blue: 0.17))
        }
        .frame(
            width: isMaximized ? max(0, screen.width - 12) : min(screen.width - 28, 430),
            height: isMaximized ? max(0, screen.height - 110) : min(screen.height * 0.61, 520)
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(.white.opacity(0.18), lineWidth: 1))
        .shadow(color: .black.opacity(0.45), radius: 28, y: 15)
        .offset(isMaximized ? .zero : windowOffset)
        .position(x: screen.width / 2, y: isMaximized ? screen.height / 2 : screen.height * 0.48)
    }

    private var filesDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("LilOS Files", isDirectory: true)
    }

    private var filesContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("On My iPhone")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    Text("\(fileURLs.count) text files")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Button {
                    newFileName = "Untitled"
                    showNewFilePrompt = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(.cyan.opacity(0.75), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Create text file")
            }

            if fileURLs.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 34))
                        .foregroundStyle(.white.opacity(0.35))
                    Text("No text files")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.75))
                    Text("Tap + to create your first file.")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(fileURLs, id: \.self) { url in
                            Button {
                                openTextFile(url)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 21))
                                        .foregroundStyle(.cyan)
                                        .frame(width: 30)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(url.lastPathComponent)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                        Text("Text document")
                                            .font(.system(size: 10))
                                            .foregroundStyle(.white.opacity(0.45))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.35))
                                }
                                .padding(12)
                                .background(.white.opacity(0.065), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteTextFile(url)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .onAppear(perform: loadTextFiles)
        .alert("New text file", isPresented: $showNewFilePrompt) {
            TextField("File name", text: $newFileName)
            Button("Create", action: createTextFile)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Your file will be saved inside Lil-OS.")
        }
    }

    private func loadTextFiles() {
        do {
            try FileManager.default.createDirectory(at: filesDirectory, withIntermediateDirectories: true)
            let urls = try FileManager.default.contentsOfDirectory(
                at: filesDirectory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            let textFiles = urls.filter { $0.pathExtension.lowercased() == "txt" }
                .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }

            if textFiles.isEmpty {
                let welcomeURL = filesDirectory.appendingPathComponent("Welcome.txt")
                try "Welcome to Lil-OS!\n\nYour own little desktop, right on your iPhone."
                    .write(to: welcomeURL, atomically: true, encoding: .utf8)
                fileURLs = [welcomeURL]
            } else {
                fileURLs = textFiles
            }
        } catch {
            saveStatus = "Couldn't load files"
            fileURLs = []
        }
    }

    private func createTextFile() {
        let requestedName = newFileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !requestedName.isEmpty else { return }

        let fileName = URL(fileURLWithPath: requestedName).lastPathComponent
        let baseName = fileName.lowercased().hasSuffix(".txt") ? String(fileName.dropLast(4)) : fileName
        let safeBaseName = baseName.isEmpty ? "Untitled" : baseName
        var destination = filesDirectory.appendingPathComponent("\(safeBaseName).txt")
        var suffix = 2

        while FileManager.default.fileExists(atPath: destination.path) {
            destination = filesDirectory.appendingPathComponent("\(safeBaseName) \(suffix).txt")
            suffix += 1
        }

        do {
            try FileManager.default.createDirectory(at: filesDirectory, withIntermediateDirectories: true)
            try "".write(to: destination, atomically: true, encoding: .utf8)
            loadTextFiles()
            openTextFile(destination)
        } catch {
            saveStatus = "Couldn't create file"
        }
    }

    private func openTextFile(_ url: URL) {
        do {
            noteText = try String(contentsOf: url, encoding: .utf8)
            noteFileURL = url
            saveStatus = "Saved"
            openApp = .notes
        } catch {
            saveStatus = "Couldn't open file"
        }
    }

    private func deleteTextFile(_ url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            if noteFileURL == url {
                noteFileURL = nil
                noteText = ""
            }
            loadTextFiles()
        } catch {
            saveStatus = "Couldn't delete file"
        }
    }

    private func saveNote() {
        do {
            try FileManager.default.createDirectory(at: filesDirectory, withIntermediateDirectories: true)
            let destination = noteFileURL ?? filesDirectory.appendingPathComponent("Welcome.txt")
            try noteText.write(to: destination, atomically: true, encoding: .utf8)
            noteFileURL = destination
            saveStatus = "Saved"
            loadTextFiles()
        } catch {
            saveStatus = "Save failed"
        }
    }

    private var notesContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(noteFileURL?.lastPathComponent ?? "Welcome.txt")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                    Text(saveStatus)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(saveStatus == "Saved" ? .green : .white.opacity(0.45))
                }
                Spacer()
                Button(action: saveNote) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.cyan)
                }
                .buttonStyle(.plain)
            }

            TextEditor(text: $noteText)
                .font(.system(size: 14, design: .monospaced))
                .scrollContentBackground(.hidden)
                .foregroundStyle(.white)
                .padding(8)
                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 9))
        }
        .padding(14)
        .onChange(of: noteText) { _ in
            saveStatus = "Unsaved changes"
        }
    }

    private var calculatorContent: some View {
        VStack(spacing: 12) {
            Spacer()
            Text(calculatorDisplay)
                .font(.system(size: 38, weight: .light, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(1).minimumScaleFactor(0.5)
                .padding(.horizontal, 8)
            let keys = [["AC", "±", "%", "÷"], ["7", "8", "9", "×"], ["4", "5", "6", "−"], ["1", "2", "3", "+"], ["0", ".", "="]]
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 9) {
                    ForEach(row, id: \.self) { key in
                        Button { calculatorTap(key) } label: {
                            Text(key).font(.system(size: 19, weight: .medium))
                                .foregroundStyle(key == "=" || ["÷","×","−","+"].contains(key) ? .white : .white.opacity(0.9))
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(key == "=" || ["÷","×","−","+"].contains(key) ? Color.cyan.opacity(0.75) : .white.opacity(key == "AC" ? 0.2 : 0.09), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            Spacer(minLength: 2)
        }
        .padding(14)
    }

    private var settingsContent: some View {
        Form {
            Section("Appearance") {
                Toggle("Dark appearance", isOn: $darkMode)
                Picker("Wallpaper", selection: $wallpaper) {
                    Text("Ocean").tag(0)
                    Text("Aurora").tag(1)
                    Text("Dusk").tag(2)
                }
            }
            Section("System") {
                LabeledContent("Version", value: "1.0")
                LabeledContent("Device", value: "iPhone")
                LabeledContent("System", value: "Lil-OS")
            }
        }
        .scrollContentBackground(.hidden)
        .tint(.cyan)
        .foregroundStyle(.white)
    }

    private var aboutContent: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "desktopcomputer").font(.system(size: 55)).foregroundStyle(.cyan)
            Text("Lil-OS").font(.system(size: 27, weight: .bold)).foregroundStyle(.white)
            Text("A desktop experience in your pocket.")
                .font(.system(size: 13)).foregroundStyle(.white.opacity(0.65))
            Text("Version 1.0 • Built with SwiftUI")
                .font(.system(size: 11)).foregroundStyle(.white.opacity(0.4))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func launch(_ app: OSApp) {
        showLauncher = false
        windowOffset = .zero
        windowDragOrigin = .zero
        isMinimized = false
        isMaximized = false
        openApp = app
    }

    private func calculatorTap(_ key: String) {
        if key == "AC" { calculatorDisplay = "0"; calculatorStored = nil; calculatorOperation = nil; calculatorFresh = true; return }
        if key == "±" { if let value = Double(calculatorDisplay) { calculatorDisplay = String(-value) }; return }
        if key == "%" { if let value = Double(calculatorDisplay) { calculatorDisplay = String(value / 100) }; return }
        if ["÷", "×", "−", "+"].contains(key) {
            calculatorStored = Double(calculatorDisplay) ?? 0
            calculatorOperation = key
            calculatorFresh = true
            return
        }
        if key == "=" {
            guard let first = calculatorStored, let op = calculatorOperation, let second = Double(calculatorDisplay) else { return }
            var result = second
            switch op {
            case "+": result = first + second
            case "−": result = first - second
            case "×": result = first * second
            case "÷": result = second == 0 ? 0 : first / second
            default: break
            }
            calculatorDisplay = result.isFinite ? String(result) : "Error"
            calculatorStored = nil
            calculatorOperation = nil
            calculatorFresh = true
            return
        }
        if key == "." {
            if calculatorFresh { calculatorDisplay = "0."; calculatorFresh = false }
            else if !calculatorDisplay.contains(".") { calculatorDisplay += "." }
            return
        }
        if calculatorFresh || calculatorDisplay == "0" { calculatorDisplay = key; calculatorFresh = false }
        else if calculatorDisplay.count < 12 { calculatorDisplay += key }
    }
}

private struct LauncherPanel: View {
    let apps: [OSApp]
    let onLaunch: (OSApp) -> Void
    let onLock: () -> Void

    @State private var searchText = ""

    private var filteredApps: [OSApp] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return apps }
        return apps.filter { $0.rawValue.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.55))

                TextField("Search apps", text: $searchText)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .submitLabel(.search)
                    .accessibilityLabel("Search apps")

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(12)
            .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 12))

            HStack {
                Text("Applications")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
                Spacer()
                Text("\(filteredApps.count)")
                    .font(.system(size: 10, weight: .medium).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.4))
            }

            if filteredApps.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "app.dashed")
                        .font(.system(size: 27))
                        .foregroundStyle(.white.opacity(0.35))
                    Text("No apps found")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                    Text("Try another search term.")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity, minHeight: 112)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(filteredApps) { app in
                        Button {
                            onLaunch(app)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: app.symbol)
                                    .foregroundStyle(app.tint)
                                    .font(.system(size: 21))
                                Text(app.rawValue)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 13, weight: .medium))
                                Spacer(minLength: 0)
                            }
                            .padding(12)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack {
                Image(systemName: "person.crop.circle.fill")
                Text("Lil-OS User")
                Spacer()
                Button(action: onLock) {
                    HStack(spacing: 6) {
                        Text("Lock desktop")
                        Image(systemName: "lock.fill")
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Lock Lil-OS desktop")
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white.opacity(0.8))
            .padding(.top, 4)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.2), lineWidth: 1))
        .padding(.horizontal, 18)
        .padding(.bottom, 94)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

