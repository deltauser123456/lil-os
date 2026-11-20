import SwiftUI

private enum TerminalTone {
    case command
    case output
    case accent
    case success
    case warning
    case error
    case muted

    var color: Color {
        switch self {
        case .command: return Color(red: 0.55, green: 0.95, blue: 0.72)
        case .output: return Color(red: 0.86, green: 0.89, blue: 0.94)
        case .accent: return Color(red: 0.42, green: 0.82, blue: 1.0)
        case .success: return Color(red: 0.47, green: 0.88, blue: 0.62)
        case .warning: return Color(red: 1.0, green: 0.78, blue: 0.36)
        case .error: return Color(red: 1.0, green: 0.42, blue: 0.42)
        case .muted: return Color.white.opacity(0.48)
        }
    }
}

private struct TerminalEntry: Identifiable {
    let id = UUID()
    let text: String
    let tone: TerminalTone
}

struct TerminalView: View {
    let onOpenApp: (String) -> Bool

    @State private var input = ""
    @State private var entries = [
        TerminalEntry(text: "Lil-OS Terminal [Version 1.0]", tone: .accent),
        TerminalEntry(text: "A local command console. Type 'help' to get started.", tone: .muted)
    ]
    @State private var commandHistory: [String] = []
    @State private var historyIndex: Int?
    @State private var sessionStartedAt = Date()
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 7, height: 7)
                Text("LIL-OS / TERMINAL")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.1)
                    .foregroundStyle(.white.opacity(0.72))
                Spacer()
                Text("LOCAL SESSION")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(.green.opacity(0.8))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(.white.opacity(0.045))

            Rectangle()
                .fill(.white.opacity(0.09))
                .frame(height: 1)

            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(entries) { entry in
                            Text(entry.text)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(entry.tone.color)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .textSelection(.enabled)
                        }

                        Color.clear
                            .frame(height: 1)
                            .id("terminal-bottom")
                    }
                    .padding(14)
                }
                .onChange(of: entries.count) { _ in
                    withAnimation(.easeOut(duration: 0.12)) {
                        scrollProxy.scrollTo("terminal-bottom", anchor: .bottom)
                    }
                }
            }

            Rectangle()
                .fill(.white.opacity(0.09))
                .frame(height: 1)

            HStack(spacing: 9) {
                Text("›")
                    .font(.system(size: 19, weight: .bold, design: .monospaced))
                    .foregroundStyle(.green)

                TextField("Enter a command…", text: $input)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .submitLabel(.go)
                    .focused($inputFocused)
                    .onSubmit(runCommand)
                    .accessibilityLabel("Terminal command")

                Button(action: showPreviousCommand) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.55))
                        .frame(width: 27, height: 30)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Previous command")

                Button(action: showNextCommand) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.55))
                        .frame(width: 27, height: 30)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Next command")

                Button(action: runCommand) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 23))
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Run command")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(.white.opacity(0.055))
        }
        .background(Color(red: 0.055, green: 0.075, blue: 0.09))
        .onAppear {
            sessionStartedAt = Date()
        }
    }

    private func appendLine(_ text: String, tone: TerminalTone = .output) {
        entries.append(TerminalEntry(text: text, tone: tone))
    }

    private func runCommand() {
        let rawCommand = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !rawCommand.isEmpty else { return }

        appendLine("junior@lil-os:~$ \(rawCommand)", tone: .command)
        commandHistory.append(rawCommand)
        historyIndex = nil
        input = ""

        let parts = rawCommand.split(
            maxSplits: 1,
            omittingEmptySubsequences: true,
            whereSeparator: { $0.isWhitespace }
        )
        let command = parts.first.map { String($0).lowercased() } ?? ""
        let argument = parts.count > 1
            ? String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            : ""

        switch command {
        case "help", "?":
            appendLine("""
            Available commands
              help             Show this help
              clear            Clear the terminal
              date             Show today's date
              time             Show the local time
              whoami           Show the current user
              hostname         Show this device's Lil-OS name
              uname            Show system information
              version          Show the Lil-OS version
              uptime           Show this terminal session length
              pwd              Show the virtual working folder
              ls               List your Lil-OS text documents
              apps             List installed Lil-OS apps
              open <app>       Open a Lil-OS app
              echo <text>      Print text
              neofetch         Show a system summary
              exit             Explain how to close this window

            Commands run locally inside Lil-OS. This is not an iOS system shell.
            """)
        case "clear", "cls":
            entries.removeAll()
        case "date":
            appendLine(Date.now.formatted(date: .complete, time: .omitted), tone: .success)
        case "time":
            appendLine(Date.now.formatted(date: .omitted, time: .standard), tone: .success)
        case "whoami":
            appendLine("junior", tone: .success)
        case "hostname":
            appendLine("lil-iphone", tone: .success)
        case "uname":
            appendLine("Lil-OS 1.0 — native SwiftUI desktop experience on iOS", tone: .success)
        case "version":
            appendLine("Lil-OS Terminal 1.0", tone: .success)
        case "uptime":
            let seconds = max(0, Int(Date().timeIntervalSince(sessionStartedAt)))
            appendLine("Terminal session: \(seconds / 60)m \(seconds % 60)s")
        case "pwd":
            appendLine("~/Documents/LilOS Files", tone: .muted)
        case "ls":
            listDocuments()
        case "apps":
            appendLine("Files  Notepad  Calculator  Calendar  Clock  Paint  Settings  Terminal  About Lil-OS")
        case "open":
            guard !argument.isEmpty else {
                appendLine("Usage: open <app name>", tone: .warning)
                return
            }
            if onOpenApp(argument) {
                appendLine("Opening \(argument)…", tone: .success)
            } else {
                appendLine("App not found: \(argument). Try 'apps' to see available apps.", tone: .error)
            }
        case "echo":
            appendLine(argument)
        case "neofetch":
            appendLine("""
                 _     _ _       ___  ____
                | |   (_) |     / _ \\/ ___|
                | |   | | |    | | | \\___ \\
                | |___| | |___ | |_| |___) |
                |_____|_|_____| \\___/|____/

                OS: Lil-OS 1.0
                Host: iPhone
                Shell: Lil-OS Terminal
                Interface: SwiftUI
                Apps: \(8)
                """, tone: .accent)
        case "exit":
            appendLine("Close the Terminal window with the red button to return to the desktop.", tone: .muted)
        default:
            appendLine("Command not found: \(command). Type 'help' for available commands.", tone: .error)
        }
    }

    private func listDocuments() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = documents.appendingPathComponent("LilOS Files", isDirectory: true)

        do {
            let urls = try FileManager.default.contentsOfDirectory(
                at: folder,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            let names = urls
                .filter { $0.pathExtension.lowercased() == "txt" }
                .map(\.lastPathComponent)
                .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }

            appendLine(names.isEmpty ? "Lil-OS Files is empty." : names.joined(separator: "\n"))
        } catch {
            appendLine("Lil-OS Files is empty. Create a document in the Files app first.", tone: .muted)
        }
    }

    private func showPreviousCommand() {
        guard !commandHistory.isEmpty else { return }
        let currentIndex = historyIndex ?? commandHistory.count
        guard currentIndex > 0 else { return }
        let nextIndex = currentIndex - 1
        historyIndex = nextIndex
        input = commandHistory[nextIndex]
    }

    private func showNextCommand() {
        guard let currentIndex = historyIndex else { return }
        let nextIndex = currentIndex + 1
        if nextIndex < commandHistory.count {
            historyIndex = nextIndex
            input = commandHistory[nextIndex]
        } else {
            historyIndex = nil
            input = ""
        }
    }
}
