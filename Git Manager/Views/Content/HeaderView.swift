import ScrechKit

struct HeaderView: View {
    let selectedPath: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(selectedPath ?? "Pick a root folder to scan for repositories")
                .callout(design: .rounded)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }
}
