import SwiftUI

@MainActor
@Observable
final class CodeLineHistoryModel {
    var mode: CodeLineGraphMode = .allTime
    
    private(set) var lineHistory: [GitCodeLinePoint]
    private(set) var isLoading = true
    private(set) var errorMessage: String?
    private var loadID = UUID()
    private let path: String
    
    init(path: String) {
        self.path = path
        lineHistory = CodeLineHistoryCache.shared.snapshot(at: path)?.points ?? []
    }
    
    var displayedHistory: [GitCodeLinePoint] { mode.points(from: lineHistory) }
    
    var emptyMessage: String {
        mode == .pastYear ? "No commits in the past year" : "No commit history available"
    }
    
    var latestPoint: GitCodeLinePoint? { lineHistory.last }
    
    var yDomain: ClosedRange<Double> {
        guard let minimum = displayedHistory.map(\.totalLines).min(),
              let maximum = displayedHistory.map(\.totalLines).max()
                else { return 0...1 }
        let spread = max(maximum - minimum, 1)
        let padding = max(Int(Double(spread) * 0.14), 12)
        return Double(max(minimum - padding, 0))...Double(maximum + padding)
    }
    
    var summaryText: String {
        let history = displayedHistory
        guard let latestPoint = history.last else { return " " }
        let deltaPrefix = latestPoint.delta > 0 ? "+" : ""
        
        return "\(history.count) commits in graph, latest change \(deltaPrefix)\(latestPoint.delta) lines"
    }
    
    func load() async {
        let requestID = UUID()
        loadID = requestID
        isLoading = true
        errorMessage = nil
        
        defer {
            if loadID == requestID { isLoading = false }
        }
        
        do {
            let revision = try await GitClient.run(["rev-parse", "HEAD"], at: path)
            try Task.checkCancellation()
            guard loadID == requestID else { return }
            
            if let snapshot = CodeLineHistoryCache.shared.snapshot(at: path), snapshot.revision == revision {
                lineHistory = snapshot.points
                return
            }
            
            let history = try await GitClient.codeLineHistory(at: path, revision: revision)
            try Task.checkCancellation()
            guard loadID == requestID else { return }
            CodeLineHistoryCache.shared.store(.init(revision: revision, points: history), at: path)
            lineHistory = history
        } catch is CancellationError {
            
        } catch {
            guard !Task.isCancelled, loadID == requestID else { return }
            errorMessage = error.localizedDescription
        }
    }
}
