import ScrechKit

struct RepoDetailCodeLinesView: View {
    let repository: GitRepository
    
    @State private var model: CodeLineHistoryModel
    
    init(repository: GitRepository) {
        self.repository = repository
        _model = State(initialValue: CodeLineHistoryModel(path: repository.path))
    }
    
    var body: some View {
        @Bindable var model = model
        
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Code lines")
                    .headline(design: .rounded)
                
                if let latestPoint = model.latestPoint {
                    Text("\(latestPoint.totalLines.formatted()) total")
                        .caption(.semibold, design: .rounded)
                        .foregroundStyle(AppTheme.accent)
                }
                
                Spacer(minLength: 0)
                
                Picker("", selection: $model.mode) {
                    ForEach(CodeLineGraphMode.allCases) {
                        Text($0.title).tag($0)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            ZStack {
                if !model.displayedHistory.isEmpty {
                    RepoDetailCodeLinesChartView()
                        .environment(model)
                } else if model.isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else if let errorMessage = model.errorMessage {
                    Text(errorMessage)
                        .caption(design: .rounded)
                        .foregroundStyle(AppTheme.warning)
                } else {
                    Text(model.emptyMessage)
                        .caption(design: .rounded)
                        .secondary()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 190)
            
            Text(model.summaryText)
                .caption(design: .rounded)
                .secondary()
                .lineLimit(1)
                .accessibilityHidden(model.displayedHistory.isEmpty)
        }
        .task(id: repository) {
            await model.load()
        }
    }
}
