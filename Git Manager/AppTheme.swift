import SwiftUI

struct AppTheme {
    static let accent = Color(red: 0.14, green: 0.45, blue: 0.38)
    static let accentSoft = Color(red: 0.86, green: 0.95, blue: 0.92)
    static let warning = Color(red: 0.78, green: 0.36, blue: 0.18)
    static let star = Color(red: 0.95, green: 0.73, blue: 0.24)

    static func backgroundGradient(for scheme: ColorScheme) -> LinearGradient {
        let colors: [Color]
        if scheme == .dark {
            colors = [
                Color(red: 0.10, green: 0.12, blue: 0.14),
                Color(red: 0.13, green: 0.16, blue: 0.20),
                Color(red: 0.08, green: 0.14, blue: 0.12)
            ]
        } else {
            colors = [
                Color(red: 0.98, green: 0.96, blue: 0.93),
                Color(red: 0.93, green: 0.97, blue: 0.98),
                Color(red: 0.95, green: 0.93, blue: 0.99)
            ]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
