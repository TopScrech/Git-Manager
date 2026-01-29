import Algorithms
import ScrechKit

struct RepoDetailCommitsView: View {
    let repository: GitRepository

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Commits")
                .headline(design: .rounded)

            if let errorMessage = repository.errorMessage {
                Text(errorMessage)
                    .caption(design: .rounded)
                    .foregroundStyle(AppTheme.warning)
            } else if repository.commits.isEmpty {
                Text(emptyMessage)
                    .caption(design: .rounded)
                    .secondary()
            } else {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(commitGroups) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(dayTitle(for: group.date))
                                .caption(.semibold, design: .rounded)
                                .secondary()

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(group.commits) { commit in
                                    CommitRowView(
                                        commit: commit,
                                        issueURL: issueURL(for: commit)
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var emptyMessage: String {
        if repository.baseRef == nil {
            return "main or master not found"
        }
        return "No new commits compared with base"
    }

    private var commitGroups: [CommitDayGroup] {
        let calendar = Calendar.current
        return repository.commits
            .chunked { calendar.isDate($0.date, inSameDayAs: $1.date) }
            .map { group in
                let date = calendar.startOfDay(for: group.first?.date ?? Date())
                return CommitDayGroup(date: date, commits: Array(group))
            }
    }

    private func issueURL(for commit: GitCommit) -> URL? {
        guard let issueNumber = commit.issueNumber else { return nil }
        guard let remoteURL = repository.remoteURL else { return nil }
        return GitRemoteURLBuilder.issueURL(remote: remoteURL, issueNumber: issueNumber)
    }

    private func dayTitle(for date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        }

        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }

        return daysAgoText(for: date, calendar: calendar)
    }

    private func daysAgoText(for date: Date, calendar: Calendar) -> String {
        let startOfDay = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        let dayCount = calendar.dateComponents([.day], from: startOfDay, to: today).day ?? 0
        let clampedDays = max(0, dayCount)
        let suffix = clampedDays == 1 ? "" : "s"
        return "\(clampedDays) day\(suffix) ago"
    }
}

private struct CommitDayGroup: Identifiable {
    let date: Date
    let commits: [GitCommit]

    var id: Date { date }
}
