import Foundation

struct RepoCacheSnapshot: Codable {
    let folderPath: String
    let repositories: [CachedRepository]
    let cachedAt: Date
}

struct CachedRepository: Codable {
    let id: String
    let name: String
    let path: String
    let remoteURL: String?
    let currentBranch: String?
    let comparisonBranch: String?
    let baseRef: String?
    let commits: [CachedCommit]
    let errorMessage: String?

    init(from repository: GitRepository) {
        id = repository.id
        name = repository.name
        path = repository.path
        remoteURL = repository.remoteURL
        currentBranch = repository.currentBranch
        comparisonBranch = repository.comparisonBranch
        baseRef = repository.baseRef
        commits = repository.commits.map(CachedCommit.init(from:))
        errorMessage = repository.errorMessage
    }

    var repository: GitRepository {
        GitRepository(
            id: id,
            name: name,
            path: path,
            remoteURL: remoteURL,
            currentBranch: currentBranch,
            comparisonBranch: comparisonBranch,
            baseRef: baseRef,
            commits: commits.map(\.commit),
            errorMessage: errorMessage
        )
    }
}

struct CachedCommit: Codable {
    let fullHash: String
    let shortHash: String
    let subject: String
    let date: Date

    init(from commit: GitCommit) {
        fullHash = commit.fullHash
        shortHash = commit.shortHash
        subject = commit.subject
        date = commit.date
    }

    var commit: GitCommit {
        GitCommit(
            fullHash: fullHash,
            shortHash: shortHash,
            subject: subject,
            date: date
        )
    }
}
