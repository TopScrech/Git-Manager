import SwiftUI

@main
struct GitManagerApp: App {
    @FocusedValue(\.searchFocus) private var searchFocus

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandMenu("Find") {
                Button("Find") {
                    searchFocus?.wrappedValue = true
                }
                .keyboardShortcut("f", modifiers: .command)
            }
        }
    }
}
