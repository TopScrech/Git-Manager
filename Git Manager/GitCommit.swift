import SwiftUI

struct GitCommit: Identifiable, Hashable {
    let fullHash: String
    let shortHash: String
    let subject: String
    let date: Date

    var id: String { fullHash }

    var relativeDateText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
