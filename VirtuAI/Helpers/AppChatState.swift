// AppChatState.swift

import SwiftUI

class AppChatState: ObservableObject {
    @Published var currentView: AnyView?

    func navigate<V: View>(to view: V) {
        currentView = AnyView(view)
    }

    @Published var hideBottomNav: Bool = false
}
