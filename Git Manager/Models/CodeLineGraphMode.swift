import Foundation

enum CodeLineGraphMode: CaseIterable, Identifiable {
    case allTime, pastYear

    var id: Self { self }

    var title: String {
        switch self {
        case .allTime: "All time"
        case .pastYear: "Past year"
        }
    }

    func points(from history: [GitCodeLinePoint], through date: Date = .now, calendar: Calendar = .current) -> [GitCodeLinePoint] {
        switch self {
        case .allTime:
            history
            
        case .pastYear:
            if let startDate = calendar.date(byAdding: .year, value: -1, to: date) {
                history.filter { $0.date >= startDate && $0.date <= date }
            } else {
                []
            }
        }
    }
}
