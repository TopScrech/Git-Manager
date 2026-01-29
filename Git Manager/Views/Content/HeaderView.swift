import ScrechKit

struct HeaderView: View {
    let selectedPath: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pick a root folder to scan for repositories")
                .callout(design: .rounded)
                .secondary()
                .lineLimit(2)
        }
    }
}
