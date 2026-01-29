import ScrechKit

struct RepoDetailHeaderView: View {
    let repository: GitRepository
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(repository.name)
                    .title3(.semibold, design: .serif)

                Text(repository.displayPath)
                    .caption(design: .monospaced)
                    .secondary()
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                RepoDetailPRButtonView(repository: repository)
                RepoDetailFavoriteButtonView(
                    isFavorite: isFavorite,
                    onToggleFavorite: onToggleFavorite
                )
            }
        }
    }
}
