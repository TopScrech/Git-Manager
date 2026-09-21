import ScrechKit

struct CommitRowView: View {
    let commit: GitCommit
    let issueLinks: [CommitIssueLink]
    
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
                        if !issueLinks.isEmpty {
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                ForEach(issueLinks.indices, id: \.self) {
                                    CommitIssueBadgeView(issueLink: issueLinks[$0])
                                }
                            }
                        }
                        
                        Text(commit.displayTimeText)
                            .caption(design: .rounded)
                            .secondary()
                    }
                }
            }
        }
    }
}
