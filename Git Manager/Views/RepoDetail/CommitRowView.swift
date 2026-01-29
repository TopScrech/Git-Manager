import ScrechKit

struct CommitRowView: View {
    let commit: GitCommit
    let issueURL: URL?
    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(AppTheme.accent.opacity(0.8))
                .frame(6)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(commit.subject)
                        .subheadline(design: .rounded)

                    Spacer(minLength: 8)

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        if let issueNumber = commit.issueNumber {
                            issueBadge(issueNumber)
                        }

                        Text(commit.displayTimeText)
                            .caption(design: .rounded)
                            .secondary()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func issueBadge(_ issueNumber: String) -> some View {
        if let issueURL {
            Button {
                openURL(issueURL)
            } label: {
                issueBadgeText(issueNumber)
            }
            .buttonStyle(.plain)
        } else {
            issueBadgeText(issueNumber)
        }
    }

    private func issueBadgeText(_ issueNumber: String) -> some View {
        Text(issueNumber)
            .caption(.semibold, design: .rounded)
            .fontWeight(.bold)
            .foregroundStyle(AppTheme.accent)
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .background(AppTheme.accentSoft, in: .capsule)
    }
}
