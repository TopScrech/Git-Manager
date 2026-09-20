import Foundation

struct CodeLineHistorySnapshot: Codable {
    let revision: String
    let points: [GitCodeLinePoint]
}
