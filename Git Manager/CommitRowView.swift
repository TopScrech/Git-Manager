import ScrechKit

struct CommitRowView: View {
    let commit: GitCommit

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(AppTheme.accent.opacity(0.8))
                .frame(6)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(commit.subject)
                    .subheadline(design: .rounded)

                HStack(spacing: 8) {
                    Text(commit.shortHash)
                        .caption(design: .monospaced)
                        .secondary()

                    Text(commit.relativeDateText)
                        .caption(design: .rounded)
                        .secondary()
                }
            }
        }
    }
}
