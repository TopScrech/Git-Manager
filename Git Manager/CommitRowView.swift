import SwiftUI

struct CommitRowView: View {
    let commit: GitCommit

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(AppTheme.accent.opacity(0.8))
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(commit.subject)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    Text(commit.shortHash)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)

                    Text(commit.relativeDateText)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
