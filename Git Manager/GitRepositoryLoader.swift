import SwiftUI

struct GitRepositoryLoader {
    static func load(at url: URL) async -> GitRepository? {
        let path = url.path
        let name = url.lastPathComponent

        do {
            let branch = try await GitClient.currentBranch(at: path)
            let baseRef = try await GitClient.baseRef(at: path)
            let comparisonBranch = try await GitClient.latestNonPrimaryBranch(
                at: path,
                baseRef: baseRef,
                currentBranch: branch
            )
            let remoteURL = await GitClient.preferredRemoteURL(at: path)
            let compareRef = comparisonBranch ?? branch
            let commits: [GitCommit]
            if let baseRef, let compareRef, compareRef != baseRef {
                commits = try await GitClient.commits(
                    aheadOf: baseRef,
                    compareRef: compareRef,
                    at: path
                )
            } else {
                commits = []
            }

            return GitRepository(
                id: path,
                name: name,
                path: path,
                remoteURL: remoteURL,
                currentBranch: branch,
                comparisonBranch: comparisonBranch,
                baseRef: baseRef,
                commits: commits,
                errorMessage: nil
            )
        } catch {
            return GitRepository(
                id: path,
                name: name,
                path: path,
                remoteURL: nil,
                currentBranch: nil,
                comparisonBranch: nil,
                baseRef: nil,
                commits: [],
                errorMessage: error.localizedDescription
            )
        }
    }
}
