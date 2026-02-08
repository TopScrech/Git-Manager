import Charts
import ScrechKit

struct RepoDetailCodeLinesView: View {
    let repository: GitRepository

    @State private var lineHistory: [GitCodeLinePoint] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Code lines")
                    .headline(design: .rounded)

                Spacer(minLength: 0)

                if let latestPoint {
                    Text("\(latestPoint.totalLines.formatted()) total")
                        .caption(.semibold, design: .rounded)
                        .foregroundStyle(AppTheme.accent)
                }
            }

            if isLoading {
                ProgressView()
                    .controlSize(.small)
            } else if let errorMessage {
                Text(errorMessage)
                    .caption(design: .rounded)
                    .foregroundStyle(AppTheme.warning)
            } else if lineHistory.isEmpty {
                Text("No commit history available")
                    .caption(design: .rounded)
                    .secondary()
            } else {
                chart
                Text(summaryText)
                    .caption(design: .rounded)
                    .secondary()
            }
        }
        .task(id: repository) {
            await loadHistory()
        }
    }

    private var latestPoint: GitCodeLinePoint? {
        lineHistory.last
    }

    private var chart: some View {
        Chart(lineHistory) { point in
            AreaMark(
                x: .value("Date", point.date),
                y: .value("Total", point.totalLines)
            )
            .interpolationMethod(.linear)
            .foregroundStyle(AppTheme.accentSoft.gradient)

            LineMark(
                x: .value("Date", point.date),
                y: .value("Total", point.totalLines)
            )
            .interpolationMethod(.linear)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .foregroundStyle(AppTheme.accent)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisGridLine()
                    .foregroundStyle(.white.opacity(0.16))
                AxisTick()
                AxisValueLabel {
                    if let dateValue = value.as(Date.self) {
                        Text(Self.dateFormatter.string(from: dateValue))
                    }
                }
            }
        }
        .chartYScale(domain: yDomain)
        .chartPlotStyle { plotArea in
            plotArea
                .background(.white.opacity(0.08), in: .rect(cornerRadius: 10, style: .continuous))
        }
        .frame(height: 190)
    }

    private var yDomain: ClosedRange<Double> {
        guard
            let minimum = lineHistory.map(\.totalLines).min(),
            let maximum = lineHistory.map(\.totalLines).max()
        else {
            return 0...1
        }

        let spread = max(maximum - minimum, 1)
        let padding = max(Int(Double(spread) * 0.14), 12)
        let lowerBound = max(minimum - padding, 0)
        let upperBound = maximum + padding
        return Double(lowerBound)...Double(upperBound)
    }

    private var summaryText: String {
        guard let latestPoint else { return "" }
        let deltaPrefix = latestPoint.delta > 0 ? "+" : ""
        return "\(lineHistory.count) commits in graph, latest change \(deltaPrefix)\(latestPoint.delta) lines"
    }

    private func loadHistory() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let history = try await GitClient.codeLineHistory(at: repository.path)
            try Task.checkCancellation()
            lineHistory = history
        } catch is CancellationError {
        } catch {
            lineHistory = []
            errorMessage = error.localizedDescription
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        return formatter
    }()
}
