import ScrechKit

struct ContentView: View {
    @StateObject private var store = RepoStore()
    @AppStorage("favoriteRepoPaths") private var favoriteRepoPaths = ""
    @AppStorage("lastSelectedRepoPath") private var lastSelectedRepoPath = ""

    @State private var isAppeared = false
    @State private var selectedRepoID: GitRepository.ID?
    @State private var searchQuery = ""
    @FocusState private var isSearchFocused: Bool

    private var favoriteSet: Set<String> {
        Set(favoriteRepoPaths.split(separator: "\n").map(String.init))
    }

    var body: some View {
        ZStack {
            BackgroundView()
            ContentSplitView(
                store: store,
                isAppeared: isAppeared,
                favoriteSet: favoriteSet,
                selectedRepoID: $selectedRepoID,
                searchQuery: $searchQuery,
                isSearchFocused: $isSearchFocused,
                displayedRepositories: displayedRepositories,
                selectedRepository: selectedRepository,
                repoCountLabel: repoCountLabel,
                onToggleFavorite: toggleFavorite
            )
        }
        .focusedSceneValue(\.searchFocus, $isSearchFocused)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAppeared = true
            }
            updateSelection(with: displayedRepositories)
        }
        .onChange(of: store.repositories) {
            updateSelection(with: displayedRepositories)
        }
        .onChange(of: searchQuery) {
            updateSelection(with: displayedRepositories)
        }
        .onChange(of: selectedRepoID) { _, newValue in
            guard let newValue else { return }
            lastSelectedRepoPath = newValue
            store.refreshRepository(id: newValue)
        }
    }

    private var sortedRepositories: [GitRepository] {
        store.repositories.sorted { lhs, rhs in
            let lhsFavorite = favoriteSet.contains(lhs.path)
            let rhsFavorite = favoriteSet.contains(rhs.path)
            if lhsFavorite != rhsFavorite {
                return lhsFavorite && !rhsFavorite
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    private var displayedRepositories: [GitRepository] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return sortedRepositories
        }
        return sortedRepositories.filter { repo in
            repo.name.localizedCaseInsensitiveContains(query)
            || repo.path.localizedCaseInsensitiveContains(query)
        }
    }

    private var repoCountLabel: String {
        if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\(store.repositories.count) repos"
        }
        return "\(displayedRepositories.count) of \(store.repositories.count) repos"
    }

    private var selectedRepository: GitRepository? {
        guard let selectedRepoID else { return nil }
        return store.repositories.first { $0.id == selectedRepoID }
    }

    private func toggleFavorite(_ path: String) {
        var set = favoriteSet
        if set.contains(path) {
            set.remove(path)
        } else {
            set.insert(path)
        }
        favoriteRepoPaths = set.sorted().joined(separator: "\n")
    }

    private func updateSelection(with repositories: [GitRepository]) {
        guard !repositories.isEmpty else {
            selectedRepoID = nil
            return
        }
        if let selectedRepoID, repositories.contains(where: { $0.id == selectedRepoID }) {
            return
        }
        if !lastSelectedRepoPath.isEmpty,
           let savedRepository = repositories.first(where: { $0.id == lastSelectedRepoPath }) {
            selectedRepoID = savedRepository.id
            return
        }
        selectedRepoID = repositories.first?.id
    }
}

#Preview {
    ContentView()
}
