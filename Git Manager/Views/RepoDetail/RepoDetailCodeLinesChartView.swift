import Charts
import ScrechKit

struct RepoDetailCodeLinesChartView: View {
    @Environment(CodeLineHistoryModel.self) private var model
    
    var body: some View {
        let history = model.displayedHistory
        
        Chart(history) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Total", point.totalLines)
            )
            .interpolationMethod(.linear)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .foregroundStyle(AppTheme.accent)
            
            if history.count == 1 {
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Total", point.totalLines)
                )
                .foregroundStyle(AppTheme.accent)
            }
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
                        Text(dateValue, format: .dateTime.month(.abbreviated).day())
                    }
                }
            }
        }
        .chartYScale(domain: model.yDomain)
        .chartPlotStyle { plotArea in
            plotArea
                .background(.white.opacity(0.08), in: .rect(cornerRadius: 10, style: .continuous))
        }
    }
}
