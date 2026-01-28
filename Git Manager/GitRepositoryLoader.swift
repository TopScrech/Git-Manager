import SwiftUI

struct GitRepositoryLoader {
    static func load(at url: URL) async -> GitRepository? {
        let path = url.path
        let name = url.lastPathComponent

        do {
            let branch = try await GitClient.currentBranch(at: path)
            let baseRef = try await GitClient.baseRef(at: path)
            let commits: [GitCommit]
            if let baseRef {
                commits = try await GitClient.commits(aheadOf: baseRef, at: path)
            } else {
                commits = []
            }

            return GitRepository(
                id: path,
                name: name,
                path: path,
                currentBranch: branch,
                baseRef: baseRef,
                commits: commits,
                errorMessage: nil
            )
        } catch {
            return GitRepository(
                id: path,
                name: name,
                path: path,
                currentBranch: nil,
                baseRef: nil,
                commits: [],
                errorMessage: error.localizedDescription
            )
        }
    }
}
