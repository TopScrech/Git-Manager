import ScrechKit

struct ContentDetailView: View {
    let repository: GitRepository?
    let favoriteSet: Set<String>
    let hasRepositories: Bool
    let hasFolder: Bool
    let onToggleFavorite: (String) -> Void

    var body: some View {
        Group {
            if let repository {
                RepoDetailView(
                    repository: repository,
                    isFavorite: favoriteSet.contains(repository.path),
                    onToggleFavorite: { onToggleFavorite(repository.path) }
                )
            } else {
                RepoDetailEmptyView(
                    hasRepositories: hasRepositories,
                    hasFolder: hasFolder
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
}
