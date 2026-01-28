import SwiftUI

struct HeaderView: View {
    let selectedPath: String?
    let isScanning: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Git Manager")
                .font(.system(.title2, design: .serif).weight(.semibold))
                .foregroundStyle(.primary)

            Text(selectedPath ?? "Pick a root folder to scan for repositories")
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)

            if isScanning {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Scanning repos")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 2)
            }
        }
    }
}
