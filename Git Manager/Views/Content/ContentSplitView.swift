import ScrechKit

struct ContentSplitView: View {
    @ObservedObject var store: RepoStore
    let isAppeared: Bool
    let favoriteSet: Set<String>
    @Binding var selectedRepoID: GitRepository.ID?
    @Binding var searchQuery: String
    let isSearchFocused: FocusState<Bool>.Binding
    let displayedRepositories: [GitRepository]
    let selectedRepository: GitRepository?
    let repoCountLabel: String
    let onToggleFavorite: (String) -> Void

    var body: some View {
        NavigationSplitView {
            ContentSidebarView(
                store: store,
                favoriteSet: favoriteSet,
                selectedRepoID: $selectedRepoID,
                searchQuery: $searchQuery,
                isSearchFocused: isSearchFocused,
                displayedRepositories: displayedRepositories,
                repoCountLabel: repoCountLabel,
                onToggleFavorite: onToggleFavorite
            )
        } detail: {
            ContentDetailView(
                repository: selectedRepository,
                favoriteSet: favoriteSet,
                hasRepositories: !store.repositories.isEmpty,
                hasFolder: store.selectedFolder != nil,
                onToggleFavorite: onToggleFavorite
            )
        }
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared ? 0 : 12)
        .animation(.easeOut(duration: 0.5), value: isAppeared)
    }
}
