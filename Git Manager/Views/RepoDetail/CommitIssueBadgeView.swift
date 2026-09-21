import SwiftUI

struct CommitIssueBadgeView: View {
    let issueLink: CommitIssueLink
    @Environment(\.openURL) private var openURL

    var body: some View {
        if let issueURL = issueLink.url {
            Button {
                openURL(issueURL)
            } label: {
                CommitIssueBadgeTextView(issueNumber: issueLink.number)
            }
            .buttonStyle(.plain)
        } else {
            CommitIssueBadgeTextView(issueNumber: issueLink.number)
        }
    }
}
