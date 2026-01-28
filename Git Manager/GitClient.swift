import SwiftUI

enum GitClientError: Error {
    case commandFailed(String)
}

struct GitClient {
    static func run(_ args: [String], at path: String) async throws -> String {
        try await Task.detached {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["git"] + args
            process.currentDirectoryURL = URL(fileURLWithPath: path)

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()

            let output = String(data: data, encoding: .utf8) ?? ""
            if process.terminationStatus != 0 {
                throw GitClientError.commandFailed(output.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            return output.trimmingCharacters(in: .whitespacesAndNewlines)
        }.value
    }

    static func currentBranch(at path: String) async throws -> String? {
        let output = try await run(["rev-parse", "--abbrev-ref", "HEAD"], at: path)
        return output.isEmpty ? nil : output
    }

    static func localBranches(at path: String) async throws -> [String] {
        let output = try await run(["branch", "--format=%(refname:short)"], at: path)
        return output.split(separator: "\n").map(String.init)
    }

    static func remoteBranches(at path: String) async throws -> [String] {
        let output = try await run(["branch", "-r", "--format=%(refname:short)"], at: path)
        return output.split(separator: "\n").map(String.init)
    }

    static func baseRef(at path: String) async throws -> String? {
        let locals = try await localBranches(at: path)
        if locals.contains("main") { return "main" }
        if locals.contains("master") { return "master" }

        let remotes = try await remoteBranches(at: path)
        if remotes.contains("origin/main") { return "origin/main" }
        if remotes.contains("origin/master") { return "origin/master" }
        return nil
    }

    static func commits(aheadOf baseRef: String, at path: String) async throws -> [GitCommit] {
        let recordSeparator = "\u{001e}"
        let fieldSeparator = "\u{001f}"
        let format = "%H\(fieldSeparator)%h\(fieldSeparator)%s\(fieldSeparator)%ct\(recordSeparator)"
        let output = try await run(["log", "--pretty=format:\(format)", "\(baseRef)..HEAD"], at: path)
        if output.isEmpty { return [] }

        return output
            .split(separator: Character(recordSeparator))
            .compactMap { line in
                let parts = line.split(separator: Character(fieldSeparator), omittingEmptySubsequences: false)
                guard parts.count == 4 else { return nil }
                let timestamp = TimeInterval(parts[3]) ?? 0
                return GitCommit(
                    fullHash: String(parts[0]),
                    shortHash: String(parts[1]),
                    subject: String(parts[2]),
                    date: Date(timeIntervalSince1970: timestamp)
                )
            }
    }
}
