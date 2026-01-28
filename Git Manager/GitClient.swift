import SwiftUI

enum GitClientError: Error {
    case commandFailed(String)
}

extension GitClientError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .commandFailed(let message):
            return message.isEmpty ? "Git command failed" : message
        }
    }
}

struct GitClient {
    static func run(_ args: [String], at path: String) async throws -> String {
        do {
            return try await runGit(args, at: path)
        } catch let error as GitClientError {
            guard case .commandFailed(let message) = error else { throw error }
            if message.localizedCaseInsensitiveContains("dubious ownership") {
                return try await runGit(["-c", "safe.directory=*"] + args, at: path)
            }
            throw error
        }
    }

    static func currentBranch(at path: String) async throws -> String? {
        do {
            let output = try await run(["rev-parse", "--abbrev-ref", "HEAD"], at: path)
            if output.isEmpty { return nil }
            if output == "HEAD" {
                return headBranchFallback(at: path)
            }
            return output
        } catch {
            if let fallback = headBranchFallback(at: path) {
                return fallback
            }
            throw error
        }
    }

    static func localBranches(at path: String) async throws -> [String] {
        let output = try await run(["for-each-ref", "refs/heads", "--format=%(refname:short)"], at: path)
        return output.split(separator: "\n").map(String.init)
    }

    static func remoteBranches(at path: String) async throws -> [String] {
        let output = try await run(["for-each-ref", "refs/remotes", "--format=%(refname:short)"], at: path)
        return output.split(separator: "\n").map(String.init)
    }

    static func preferredRemoteURL(at path: String) async -> String? {
        if let origin = try? await run(["remote", "get-url", "origin"], at: path), !origin.isEmpty {
            return origin
        }

        guard let remotes = try? await run(["remote"], at: path), !remotes.isEmpty else {
            return nil
        }

        guard let first = remotes.split(separator: "\n").map(String.init).first else {
            return nil
        }

        if let url = try? await run(["remote", "get-url", first], at: path), !url.isEmpty {
            return url
        }

        return nil
    }

    static func baseRef(at path: String) async throws -> String? {
        let locals = try await localBranches(at: path)
        if locals.contains("main") { return "main" }
        if locals.contains("master") { return "master" }
        return nil
    }

    static func latestNonPrimaryBranch(
        at path: String,
        baseRef: String?,
        currentBranch: String?
    ) async throws -> String? {
        var excluded: Set<String> = ["main", "master"]
        if let baseRef { excluded.insert(baseRef) }
        if let local = try await latestBranch(in: "refs/heads", excluding: excluded, at: path) {
            return local
        }
        if let currentBranch, !excluded.contains(currentBranch) {
            return currentBranch
        }
        return nil
    }

    static func commits(aheadOf baseRef: String, compareRef: String, at path: String) async throws -> [GitCommit] {
        let recordSeparator = "\u{001e}"
        let fieldSeparator = "\u{001f}"
        let format = "%H\(fieldSeparator)%h\(fieldSeparator)%s\(fieldSeparator)%ct\(recordSeparator)"
        let output = try await run(["log", "--pretty=format:\(format)", "\(baseRef)..\(compareRef)"], at: path)
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

    private static func runGit(_ args: [String], at path: String) async throws -> String {
        try await Task.detached {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["git"] + args
            process.currentDirectoryURL = URL(fileURLWithPath: path)
            process.environment = gitEnvironment()

            let stdout = Pipe()
            let stderr = Pipe()
            process.standardOutput = stdout
            process.standardError = stderr

            try process.run()
            let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
            let errorData = stderr.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()

            let output = String(data: outputData, encoding: .utf8) ?? ""
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            if process.terminationStatus != 0 {
                let message = errorOutput.trimmingCharacters(in: .whitespacesAndNewlines)
                let fallback = output.trimmingCharacters(in: .whitespacesAndNewlines)
                throw GitClientError.commandFailed(message.isEmpty ? fallback : message)
            }

            return output.trimmingCharacters(in: .whitespacesAndNewlines)
        }.value
    }

    nonisolated private static func gitEnvironment() -> [String: String] {
        var environment = ProcessInfo.processInfo.environment
        environment["GIT_TERMINAL_PROMPT"] = "0"
        environment["GIT_OPTIONAL_LOCKS"] = "0"
        environment["GIT_CONFIG_NOSYSTEM"] = "1"
        environment["GIT_CONFIG_GLOBAL"] = "/dev/null"
        return environment
    }

    private static func headBranchFallback(at path: String) -> String? {
        guard let gitDir = gitDirectory(at: path) else { return nil }
        let headURL = gitDir.appendingPathComponent("HEAD")
        guard let head = try? String(contentsOf: headURL) else { return nil }
        let trimmed = head.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("ref:") else { return nil }
        let ref = trimmed.replacingOccurrences(of: "ref:", with: "").trimmingCharacters(in: .whitespaces)
        return ref.split(separator: "/").last.map(String.init)
    }

    private static func latestBranch(
        in reference: String,
        excluding excluded: Set<String>,
        at path: String
    ) async throws -> String? {
        let output = try await run(
            ["for-each-ref", reference, "--sort=-committerdate", "--format=%(refname:short)"],
            at: path
        )
        for line in output.split(separator: "\n") {
            let name = String(line)
            if !excluded.contains(name) {
                return name
            }
        }
        return nil
    }

    private static func gitDirectory(at path: String) -> URL? {
        let repoURL = URL(fileURLWithPath: path)
        let dotGit = repoURL.appendingPathComponent(".git")
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: dotGit.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return dotGit
            }

            if let contents = try? String(contentsOf: dotGit) {
                let trimmed = contents.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.hasPrefix("gitdir:") {
                    let gitDirPath = trimmed.replacingOccurrences(of: "gitdir:", with: "")
                        .trimmingCharacters(in: .whitespaces)
                    let gitDirURL = URL(fileURLWithPath: gitDirPath, relativeTo: repoURL)
                    return gitDirURL.standardizedFileURL
                }
            }
        }

        return nil
    }
}
