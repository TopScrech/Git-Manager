import ScrechKit

struct RepoDetailView: View {
    let repository: GitRepository
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                RepoDetailHeaderView(
                    repository: repository,
                    isFavorite: isFavorite,
                    onToggleFavorite: onToggleFavorite
                )
                RepoDetailStatusView(repository: repository)
                RepoDetailCommitsView(repository: repository)
            }
            .padding(20)
            .background(.thinMaterial, in: .rect(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 0.8)
            )
            .padding(20)
            .frame(maxWidth: 760, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
