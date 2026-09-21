import ScrechKit

struct RepoDetailEmptyView: View {
    let hasRepositories: Bool
    let hasFolder: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .title(.semibold)
                .secondary()
            
            Text(title)
                .headline(design: .serif)
                .foregroundStyle(.primary)
            
            Text(subtitle)
                .caption(design: .rounded)
                .secondary()
        }
        .padding(22)
        .background(.thinMaterial, in: .rect(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.25), lineWidth: 0.8)
        )
        .frame(maxWidth: 340)
    }
    
    private var iconName: String {
        if hasRepositories {
            "rectangle.on.rectangle"
        } else {
            hasFolder ? "tray" : "folder"
        }
    }
    
    private var title: String {
        if hasRepositories {
            "Select a repository"
        } else {
            hasFolder ? "No repositories found" : "Choose a folder"
        }
    }
    
    private var subtitle: String {
        if hasRepositories {
            "Pick a repo in the sidebar to see commits"
        } else {
            hasFolder ? "Try a broader folder or add repos" : "We will scan that folder and stop at repo roots"
        }
    }
}
