import SwiftUI

extension View {
    @ViewBuilder
    func searchFocus(_ isFocused: FocusState<Bool>.Binding) -> some View {
        if #available(macOS 15, *) {
            self.searchFocused(isFocused)
        } else {
            self
        }
    }
}
