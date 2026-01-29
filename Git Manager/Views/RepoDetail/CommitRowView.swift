import ScrechKit

struct CommitRowView: View {
    let commit: GitCommit
    let issueLinks: [CommitIssueLink]
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
                        issueBadges()

                        Text(commit.displayTimeText)
                            .caption(design: .rounded)
                            .secondary()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func issueBadges() -> some View {
        if !issueLinks.isEmpty {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                ForEach(issueLinks.indices, id: \.self) { index in
                    issueBadge(issueLinks[index])
                }
            }
        }
    }

    @ViewBuilder
    private func issueBadge(_ issueLink: CommitIssueLink) -> some View {
        if let issueURL = issueLink.url {
            Button {
                openURL(issueURL)
            } label: {
                issueBadgeText(issueLink.number)
            }
            .buttonStyle(.plain)
        } else {
            issueBadgeText(issueLink.number)
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

struct CommitIssueLink: Hashable {
    let number: String
    let url: URL?
}
