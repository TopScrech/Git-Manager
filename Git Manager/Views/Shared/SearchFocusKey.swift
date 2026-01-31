import SwiftUI

private struct SearchFocusKey: FocusedValueKey {
    typealias Value = FocusState<Bool>.Binding
}

extension FocusedValues {
    var searchFocus: FocusState<Bool>.Binding? {
        get { self[SearchFocusKey.self] }
        set { self[SearchFocusKey.self] = newValue }
    }
}
