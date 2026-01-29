import SwiftUI

struct GitRepository: Identifiable, Hashable {
    let id: String
    let name: String
    let path: String
    let remoteURL: String?
    let currentBranch: String?
    let comparisonBranch: String?
    let baseRef: String?
    let commits: [GitCommit]
    let errorMessage: String?

    var aheadCount: Int { commits.count }
    var displayPath: String { PathDisplay.compact(path) }
}
