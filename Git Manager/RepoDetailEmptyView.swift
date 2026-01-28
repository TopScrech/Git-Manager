import SwiftUI

struct RepoDetailEmptyView: View {
    let hasRepositories: Bool
    let hasFolder: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(22)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.25), lineWidth: 0.8)
        )
        .frame(maxWidth: 340)
    }

    private var iconName: String {
        if hasRepositories {
            return "rectangle.on.rectangle"
        }
        return hasFolder ? "tray" : "folder"
    }

    private var title: String {
        if hasRepositories {
            return "Select a repository"
        }
        return hasFolder ? "No repositories found" : "Choose a folder"
    }

    private var subtitle: String {
        if hasRepositories {
            return "Pick a repo in the sidebar to see commits"
        }
        return hasFolder ? "Try a broader folder or add repos" : "We will scan that folder and stop at repo roots"
    }
}
