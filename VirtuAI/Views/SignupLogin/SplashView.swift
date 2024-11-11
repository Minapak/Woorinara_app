import SwiftUI
import Firebase
import SwiftKeychainWrapper
import AlertToast

struct SplashView: View {
    @EnvironmentObject var appChatState: AppChatState
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var isCheckingLogin = true
    private let tokenManager = TokenManager.shared
    @AppStorage("hasPerformedInitialTokenRefresh") private var hasPerformedInitialTokenRefresh = false

    var body: some View {
        VStack {
            if isCheckingLogin {
                ZStack {
                    Color.background.edgesIgnoringSafeArea(.all)
                    Image("Splash")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                }
            } else if isLoggedIn {
                ContentView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            checkLoginStatus()
        }
    }

    private func checkLoginStatus() {
        if !hasPerformedInitialTokenRefresh {
            tokenManager.checkAndRefreshTokenIfNeeded { isSuccess in
                DispatchQueue.main.async {
                    self.hasPerformedInitialTokenRefresh = true
                    if isSuccess {
                        self.isLoggedIn = true
                        self.appChatState.isUserLoggedIn = true
                        self.attemptAutoLogin()
                    } else {
                        self.isCheckingLogin = false
                    }
                }
            }
        } else {
            tokenManager.checkAndRefreshTokenIfNeeded { isSuccess in
                DispatchQueue.main.async {
                    if isSuccess {
                        self.isLoggedIn = true
                        self.appChatState.isUserLoggedIn = true
                        self.attemptAutoLogin()
                    } else {
                        self.isCheckingLogin = false
                    }
                }
            }
        }
    }

    private func attemptAutoLogin() {
        guard let savedUsername = KeychainWrapper.standard.string(forKey: "username"),
              let savedPassword = KeychainWrapper.standard.string(forKey: "password"),
              let tokenDate = UserDefaults.standard.object(forKey: "tokenDate") as? Date else {
            logOut()
            isCheckingLogin = false
            return
        }

        if Date().timeIntervalSince(tokenDate) > 24 * 60 * 60 {
            logOut()
            isLoggedIn = false
            isCheckingLogin = false
            return
        }

        updateAppStateWithUserInfo(username: savedUsername, password: savedPassword)
        isLoggedIn = true
        isCheckingLogin = false
    }

    private func updateAppStateWithUserInfo(username: String, password: String) {
        appChatState.username = username
        appChatState.password = password
        appChatState.isUserLoggedIn = true
    }

    private func logOut() {
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "refreshToken")
        KeychainWrapper.standard.removeObject(forKey: "username")
        KeychainWrapper.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "userStatus")
        UserDefaults.standard.removeObject(forKey: "userRole")
        UserDefaults.standard.removeObject(forKey: "tokenDate")
        
        isLoggedIn = false
        appChatState.isUserLoggedIn = false
    }
}
