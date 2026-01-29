import ScrechKit

struct RepoListRowView: View {
    let repository: GitRepository
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(repository.name)
                        .headline(design: .serif)
                        .foregroundStyle(.primary)

                    Text(repository.path)
                        .caption(design: .monospaced)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                Spacer(minLength: 0)

                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundStyle(isFavorite ? AppTheme.star : .secondary)
                        .padding(6)
                        .background(.thinMaterial, in: .circle)
                }
                .buttonStyle(.plain)
                .help(isFavorite ? "Unfavorite" : "Favorite")
            }

            if let errorMessage = repository.errorMessage {
                Text(errorMessage)
                    .caption(design: .rounded)
                    .foregroundStyle(AppTheme.warning)
                    .lineLimit(1)
            } else {
                statusRow
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
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
        .foregroundStyle(.secondary)
    }
}
