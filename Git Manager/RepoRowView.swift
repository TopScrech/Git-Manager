import SwiftUI

struct RepoRowView: View {
    let repository: GitRepository
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(repository.name)
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(.primary)

                    Text(repository.path)
                        .font(.system(.caption, design: .monospaced))
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

            statusRow

            if let errorMessage = repository.errorMessage {
                Text(errorMessage)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(AppTheme.warning)
            } else if repository.commits.isEmpty {
                Text(emptyMessage)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            } else {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(repository.commits) { commit in
                        CommitRowView(commit: commit)
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.25), lineWidth: 0.8)
        )
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
        .font(.system(.caption, design: .rounded))
        .foregroundStyle(.secondary)
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
}
