import ScrechKit

struct ContentSidebarView: View {
    @ObservedObject var store: RepoStore
    let favoriteSet: Set<String>
    @Binding var selectedRepoID: GitRepository.ID?
    @Binding var searchQuery: String
    let displayedRepositories: [GitRepository]
    let repoCountLabel: String
    let onToggleFavorite: (String) -> Void
    private let sidebarPadding: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HeaderView(selectedPath: store.selectedFolder?.path)
            ContentControlRowView(store: store, repoCountLabel: repoCountLabel)
            
            if store.repositories.isEmpty {
                EmptyStateView(hasFolder: store.selectedFolder != nil)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List(selection: $selectedRepoID) {
                    ForEach(displayedRepositories) { repo in
                        RepoListRowView(
                            repository: repo,
                            isFavorite: favoriteSet.contains(repo.path),
                            onToggleFavorite: { onToggleFavorite(repo.path) }
                        )
                        .tag(repo.id)
                        .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(.plain)
                .padding(.horizontal, -sidebarPadding)
                .scrollContentBackground(.hidden)
                .searchable(text: $searchQuery, placement: .sidebar, prompt: "Search repositories")
            }
        }
        .padding(sidebarPadding)
        .frame(minWidth: 300, idealWidth: 360, maxWidth: 420, maxHeight: .infinity, alignment: .topLeading)
    }
}
