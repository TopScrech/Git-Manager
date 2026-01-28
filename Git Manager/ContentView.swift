import SwiftUI

struct ContentView: View {
    @StateObject private var store = RepoStore()
    @AppStorage("favoriteRepoPaths") private var favoriteRepoPaths = ""
    @State private var isAppeared = false
    @State private var selectedRepoID: GitRepository.ID?

    private var favoriteSet: Set<String> {
        Set(favoriteRepoPaths.split(separator: "\n").map(String.init))
    }

    var body: some View {
        ZStack {
            BackgroundView()
            content
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAppeared = true
            }
            updateSelection(with: store.repositories)
        }
        .onChange(of: store.repositories) { _, newValue in
            updateSelection(with: newValue)
        }
    }

    private var content: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared ? 0 : 12)
        .animation(.easeOut(duration: 0.5), value: isAppeared)
    }

    private var controlRow: some View {
        HStack(spacing: 10) {
            Button {
                Task {
                    if let url = await FolderPicker.pickFolder() {
                        store.selectFolder(url)
                        store.scan(url)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "folder")
                    Text("Choose Folder")
                }
                .font(.system(.callout, design: .rounded).weight(.semibold))
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(AppTheme.accent, in: .capsule)
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            if store.isScanning {
                ProgressView()
                    .controlSize(.small)
                    .padding(8)
                    .background(.thinMaterial, in: .circle)
                    .frame(width: 32, height: 32)
            } else {
                Button {
                    store.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(.callout, design: .rounded).weight(.semibold))
                        .padding(8)
                        .background(.thinMaterial, in: .circle)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .disabled(store.selectedFolder == nil)
            }

            Spacer()

            if store.selectedFolder != nil {
                Text("\(store.repositories.count) repos")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var sidebarContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HeaderView(
                selectedPath: store.selectedFolder?.path
            )

            controlRow

            if store.repositories.isEmpty {
                EmptyStateView(hasFolder: store.selectedFolder != nil)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List(selection: $selectedRepoID) {
                    ForEach(sortedRepositories) { repo in
                        RepoListRowView(
                            repository: repo,
                            isFavorite: favoriteSet.contains(repo.path),
                            onToggleFavorite: { toggleFavorite(repo.path) }
                        )
                        .tag(repo.id)
                    }
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
            }
        }
        .padding(20)
        .frame(minWidth: 300, idealWidth: 360, maxWidth: 420, maxHeight: .infinity, alignment: .topLeading)
    }

    private var detailContent: some View {
        Group {
            if let repository = selectedRepository {
                RepoDetailView(
                    repository: repository,
                    isFavorite: favoriteSet.contains(repository.path),
                    onToggleFavorite: { toggleFavorite(repository.path) }
                )
            } else {
                RepoDetailEmptyView(
                    hasRepositories: !store.repositories.isEmpty,
                    hasFolder: store.selectedFolder != nil
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
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
        selectedRepoID = repositories.first?.id
    }
}

#Preview {
    ContentView()
}
