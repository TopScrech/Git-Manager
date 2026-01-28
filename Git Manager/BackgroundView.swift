import SwiftUI

struct BackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient(for: colorScheme)
            GeometryReader { proxy in
                let size = proxy.size

                Circle()
                    .fill(AppTheme.accent.opacity(colorScheme == .dark ? 0.2 : 0.12))
                    .frame(width: size.width * 0.55, height: size.width * 0.55)
                    .blur(radius: 60)
                    .offset(x: -size.width * 0.25, y: -size.height * 0.35)

                RoundedRectangle(cornerRadius: 48, style: .continuous)
                    .fill(AppTheme.accentSoft.opacity(colorScheme == .dark ? 0.16 : 0.5))
                    .frame(width: size.width * 0.6, height: size.height * 0.35)
                    .rotationEffect(.degrees(12))
                    .offset(x: size.width * 0.22, y: size.height * 0.28)
                    .blur(radius: 24)
            }
        }
        .ignoresSafeArea()
    }
}
