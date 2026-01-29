import ScrechKit

struct ContentControlRowView: View {
    @ObservedObject var store: RepoStore
    let repoCountLabel: String

    var body: some View {
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
                .callout(.semibold, design: .rounded)
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
                    .frame(32)
            } else {
                Button {
                    store.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .callout(.semibold, design: .rounded)
                        .padding(8)
                        .background(.thinMaterial, in: .circle)
                        .frame(32)
                }
                .buttonStyle(.plain)
                .disabled(store.selectedFolder == nil)
            }

            Spacer()

            if store.selectedFolder != nil {
                Text(repoCountLabel)
                    .caption(design: .rounded)
                    .secondary()
            }
        }
    }
}
