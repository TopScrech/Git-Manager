import ScrechKit

struct CommitIssueBadgeTextView: View {
    let issueNumber: String

    var body: some View {
        Text(issueNumber)
            .caption(.semibold, design: .rounded)
            .bold()
            .foregroundStyle(AppTheme.accent)
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .background(AppTheme.accentSoft, in: .capsule)
    }
}
