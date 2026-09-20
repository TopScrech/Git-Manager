import CryptoKit
import Foundation

@MainActor
final class CodeLineHistoryCache {
    static let shared = CodeLineHistoryCache()

    private var snapshots: [String: CodeLineHistorySnapshot] = [:]

    func snapshot(at path: String) -> CodeLineHistorySnapshot? {
        if let snapshot = snapshots[path] { return snapshot }
        guard let data = try? Data(contentsOf: fileURL(for: path)),
              let snapshot = try? JSONDecoder().decode(CodeLineHistorySnapshot.self, from: data)
        else { return nil }
        snapshots[path] = snapshot
        return snapshot
    }

    func store(_ snapshot: CodeLineHistorySnapshot, at path: String) {
        snapshots[path] = snapshot
        let url = fileURL(for: path)
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: url, options: .atomic)
        } catch {
            // Keep the in-memory cache when disk caching is unavailable
        }
    }

    private func fileURL(for path: String) -> URL {
        let digest = SHA256.hash(data: Data(path.utf8))
        let name = digest.map { String(Int($0) + 256, radix: 16).suffix(2) }.joined()
        return URL.cachesDirectory
            .appending(path: "dev.topscrech.Git-Manager/CodeLineHistory-v1", directoryHint: .isDirectory)
            .appending(path: name + ".json")
    }
}
