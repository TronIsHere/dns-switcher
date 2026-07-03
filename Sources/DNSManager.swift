import Foundation

struct DNSManager {
    static func listNetworkServices() -> [String] {
        runCommand(executable: "/usr/sbin/networksetup", arguments: ["-listallnetworkservices"])
            .components(separatedBy: "\n")
            .dropFirst()
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("*") && !$0.contains("asterisk") }
    }

    static func getCurrentDNS(for service: String) -> [String] {
        let output = runCommand(
            executable: "/usr/sbin/networksetup",
            arguments: ["-getdnsservers", service]
        ).trimmingCharacters(in: .whitespacesAndNewlines)

        if output.isEmpty || output.contains("There aren't any DNS Servers") {
            return []
        }

        return output
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    static func setDNS(servers: [String], for service: String) async throws {
        guard !servers.isEmpty else {
            throw DNSError.commandFailed("At least one DNS server is required.")
        }
        try await runWithAdminPrivileges(
            executable: "/usr/sbin/networksetup",
            arguments: ["-setdnsservers", service] + servers
        )
    }

    static func resetToAutomatic(for service: String) async throws {
        try await runWithAdminPrivileges(
            executable: "/usr/sbin/networksetup",
            arguments: ["-setdnsservers", service, "Empty"]
        )
    }

    private static func runCommand(executable: String, arguments: [String]) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return ""
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    private static func runWithAdminPrivileges(executable: String, arguments: [String]) async throws {
        let shellCommand = ([executable] + arguments)
            .map(shellQuote)
            .joined(separator: " ")

        let escapedForAppleScript = shellCommand
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let script = "do shell script \"\(escapedForAppleScript)\" with administrator privileges"

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
                process.arguments = ["-e", script]

                let errorPipe = Pipe()
                process.standardError = errorPipe

                do {
                    try process.run()
                    process.waitUntilExit()

                    if process.terminationStatus == 0 {
                        continuation.resume()
                    } else {
                        let errData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                        let message = String(data: errData, encoding: .utf8)?
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        continuation.resume(throwing: DNSError.commandFailed(message ?? "Command failed"))
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private static func shellQuote(_ argument: String) -> String {
        "'" + argument.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}

enum DNSError: LocalizedError {
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .commandFailed(let message):
            return message
        }
    }
}
