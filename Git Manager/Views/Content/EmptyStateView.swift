import ScrechKit

struct EmptyStateView: View {
    let hasFolder: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: hasFolder ? "tray" : "folder")
                .title(.semibold)
                .secondary()

            Text(hasFolder ? "No repositories found" : "Choose a folder to start")
                .headline(design: .serif)
                .foregroundStyle(.primary)

            Text(hasFolder ? "Try a broader folder or add repos" : "We will scan that folder and stop at repo roots")
                .caption(design: .rounded)
                .secondary()
        }
        .padding(20)
        .background(.thinMaterial, in: .rect(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.25), lineWidth: 0.8)
        )
        .frame(maxWidth: 320)
    }
}
