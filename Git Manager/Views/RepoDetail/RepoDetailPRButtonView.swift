import ScrechKit

struct RepoDetailPRButtonView: View {
    let repository: GitRepository
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            guard let prURL else { return }
            openURL(prURL)
        } label: {
            Label("Create PR", systemImage: "arrow.up.right.square")
                .caption(.semibold, design: .rounded)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(.thinMaterial, in: .capsule)
        }
        .buttonStyle(.plain)
        .disabled(prURL == nil)
        .help(prButtonHelp)
    }

    private var prURL: URL? {
        guard let baseRef = repository.baseRef else { return nil }
        guard let compareBranch = repository.comparisonBranch ?? repository.currentBranch else { return nil }
        guard compareBranch != baseRef else { return nil }
        guard let remoteURL = repository.remoteURL else { return nil }
        return GitRemoteURLBuilder.pullRequestURL(
            remote: remoteURL,
            base: baseRef,
            head: compareBranch
        )
    }

    private var prButtonHelp: String {
        if repository.baseRef == nil {
            return "main or master not found"
        }
        if repository.comparisonBranch == nil && repository.currentBranch == nil {
            return "No branch to compare"
        }
        if repository.remoteURL == nil {
            return "No remote found"
        }
        if prURL == nil {
            return "PR URL unavailable"
        }
        return "Create pull request"
    }
}
