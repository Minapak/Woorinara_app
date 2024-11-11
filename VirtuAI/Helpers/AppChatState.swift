import SwiftUI

class AppChatState: ObservableObject {
    @Published var currentView: AnyView?
    @Published var hideBottomNav: Bool = false
    @Published var isUserLoggedIn: Bool = false // 로그인 상태를 나타내는 변수
    @Published var username: String = "" // 로그인된 사용자의 이름을 저장하는 변수
    @Published var password: String = "" // 로그인된 사용자의 이름을 저장하는 변수
    func navigate<V: View>(to view: V) {
        currentView = AnyView(view)
    }
}
