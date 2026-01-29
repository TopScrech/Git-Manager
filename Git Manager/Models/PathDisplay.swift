import Foundation

enum PathDisplay {
    static func compact(_ path: String) -> String {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return path }
        let lastComponent = URL(fileURLWithPath: trimmed).lastPathComponent
        guard !lastComponent.isEmpty else { return path }
        return ".../\(lastComponent)"
    }
}
