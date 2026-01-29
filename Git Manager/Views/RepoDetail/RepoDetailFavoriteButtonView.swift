import ScrechKit

struct RepoDetailFavoriteButtonView: View {
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        Button(action: onToggleFavorite) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundStyle(isFavorite ? AppTheme.star : .secondary)
                .padding(6)
                .background(.thinMaterial, in: .circle)
        }
        .buttonStyle(.plain)
        .help(isFavorite ? "Unfavorite" : "Favorite")
    }
}
