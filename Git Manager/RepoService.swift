import SwiftUI

struct RepoService {
    static func loadRepositories(in rootURL: URL) async -> [GitRepository] {
        let repoURLs = RepositoryScanner.findRepositories(in: rootURL)
        if repoURLs.isEmpty { return [] }

        return await withTaskGroup(of: GitRepository?.self) { group in
            for url in repoURLs {
                group.addTask {
                    await GitRepositoryLoader.load(at: url)
                }
            }

            var repositories: [GitRepository] = []
            for await repo in group {
                if let repo {
                    repositories.append(repo)
                }
            }

            return repositories.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        }
    }
}
