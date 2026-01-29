import ScrechKit

struct RepoDetailStatusView: View {
    let repository: GitRepository

    var body: some View {
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
}
