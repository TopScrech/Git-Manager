import SwiftUI

struct GitCommit: Identifiable, Hashable {
    let fullHash: String
    let shortHash: String
    let subject: String
    let date: Date

    var id: String { fullHash }
    var issueNumber: String? {
        guard let match = subject.firstMatch(of: Self.issueRegex) else { return nil }
        return String(match.output)
    }
    var hasIssueNumber: Bool { issueNumber != nil }

    var displayTimeText: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return Self.relativeFormatter.localizedString(for: date, relativeTo: Date())
        }
        return Self.timeFormatter.string(from: date)
    }

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private static let issueRegex = /#\d+/
}
