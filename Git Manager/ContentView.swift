import SwiftUI

struct ContentView: View {
    @StateObject private var store = RepoStore()
    @AppStorage("favoriteRepoPaths") private var favoriteRepoPaths = ""
    @State private var isAppeared = false

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
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 14) {
            HeaderView(
                selectedPath: store.selectedFolder?.path,
                isScanning: store.isScanning
            )

            controlRow

            if store.repositories.isEmpty {
                EmptyStateView(hasFolder: store.selectedFolder != nil)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(sortedRepositories, id: \.id) { repo in
                            RepoRowView(
                                repository: repo,
                                isFavorite: favoriteSet.contains(repo.path),
                                onToggleFavorite: { toggleFavorite(repo.path) }
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: 900)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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

            Button {
                store.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(.callout, design: .rounded).weight(.semibold))
                    .padding(8)
                    .background(.thinMaterial, in: .circle)
            }
            .buttonStyle(.plain)
            .disabled(store.selectedFolder == nil || store.isScanning)

            Spacer()

            if store.selectedFolder != nil {
                Text("\(store.repositories.count) repos")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
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

    private func toggleFavorite(_ path: String) {
        var set = favoriteSet
        if set.contains(path) {
            set.remove(path)
        } else {
            set.insert(path)
        }
        favoriteRepoPaths = set.sorted().joined(separator: "\n")
    }
}

#Preview {
    ContentView()
}
