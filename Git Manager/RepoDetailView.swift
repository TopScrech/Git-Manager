import ScrechKit

struct RepoDetailView: View {
    let repository: GitRepository
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                headerRow
                statusRow
                detailSection
            }
            .padding(20)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 0.8)
            )
            .padding(20)
            .frame(maxWidth: 760, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var headerRow: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(repository.name)
                    .title3(.semibold, design: .serif)

                Text(repository.path)
                    .caption(design: .monospaced)
                    .secondary()
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                prButton
                favoriteButton
            }
        }
    }

    private var prButton: some View {
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

    private var favoriteButton: some View {
        Button(action: onToggleFavorite) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundStyle(isFavorite ? AppTheme.star : .secondary)
                .padding(6)
                .background(.thinMaterial, in: .circle)
        }
        .buttonStyle(.plain)
        .help(isFavorite ? "Unfavorite" : "Favorite")
    }

    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Commits")
                .headline(design: .rounded)

            if let errorMessage = repository.errorMessage {
                Text(errorMessage)
                    .caption(design: .rounded)
                    .foregroundStyle(AppTheme.warning)
            } else if repository.commits.isEmpty {
                Text(emptyMessage)
                    .caption(design: .rounded)
                    .secondary()
            } else {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(repository.commits) { commit in
                        CommitRowView(commit: commit)
                    }
                }
            }
        }
    }

    private var statusRow: some View {
        HStack(spacing: 10) {
            if let comparisonBranch = repository.comparisonBranch {
                Label("Latest \(comparisonBranch)", systemImage: "clock")
                    .labelStyle(.titleAndIcon)
                if let branch = repository.currentBranch, branch != comparisonBranch {
                    Label("Checked out \(branch)", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                        .labelStyle(.titleAndIcon)
                }
            } else if let branch = repository.currentBranch {
                Label(branch, systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    .labelStyle(.titleAndIcon)
            } else {
                Label("No branch", systemImage: "questionmark.circle")
                    .labelStyle(.titleAndIcon)
            }

            if let base = repository.baseRef {
                Label("Base \(base)", systemImage: "arrow.turn.up.left")
                    .labelStyle(.titleAndIcon)
            } else {
                Label("No main or master", systemImage: "exclamationmark.triangle")
                    .labelStyle(.titleAndIcon)
            }

            if repository.aheadCount > 0 {
                Label("\(repository.aheadCount) new", systemImage: "sparkles")
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(AppTheme.accent)
            } else {
                Label("Up to date", systemImage: "checkmark.circle")
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(.secondary)
            }
        }
        .caption(design: .rounded)
        .secondary()
    }

    private var emptyMessage: String {
        if repository.baseRef == nil {
            return "main or master not found"
        }
        if let comparisonBranch = repository.comparisonBranch {
            return "No new commits on \(comparisonBranch) compared with \(repository.baseRef ?? "base")"
        }
        return "No new commits compared with \(repository.baseRef ?? "base")"
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
