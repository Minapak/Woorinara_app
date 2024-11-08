import SwiftUI
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper
import AlertToast

struct SplashView: View {
    @EnvironmentObject var appChatState: AppChatState
    @State private var isActive: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showingSuccessAlert: Bool = false
    @State private var isLoginSuccessful: Bool = false
    @State private var showingAlert = false
    @State private var isLoggedIn = false
    @State private var isCheckingLogin = true
    
    private let tokenManager = TokenManager.shared
    @AppStorage("hasPerformedInitialTokenRefresh") private var hasPerformedInitialTokenRefresh = false // 최초 갱신 여부 저장

    var body: some View {
        VStack {
            if isCheckingLogin {
                ZStack {
                    Color.background
                        .edgesIgnoringSafeArea(.all)
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
            print("📲 SplashView appeared - checkAccessTokenDate.")
            checkAccessTokenDate()
            print("📲 SplashView appeared - starting checkLoginStatus.")
            checkLoginStatus()
       
        }
    }

    private func checkAccessTokenDate() {
        print("⏱ Starting checkAccessTokenDate.")
        
        DispatchQueue.global().async {
            if let accessToken = KeychainWrapper.standard.string(forKey: "accessToken"),
               let tokenDate = UserDefaults.standard.object(forKey: "tokenDate") as? Date {
                print("🔑 Access token found: \(accessToken)")
                print("📅 Token date found: \(tokenDate)")
                
                if !Calendar.current.isDateInToday(tokenDate) {
                    print("🗓 Token date is not today. Logging out.")
                    logOut()
                    isLoggedIn = false
                } else {
                    print("🗓 Token date is today. User is logged in.")
                    isLoggedIn = true
                }
            } else {
                print("❗ Access token or token date missing. User is logged out.")
                isLoggedIn = false
            }
            
            DispatchQueue.main.async {
                isCheckingLogin = false
                print("✅ checkAccessTokenDate completed. isLoggedIn: \(isLoggedIn), isCheckingLogin: \(isCheckingLogin)")
            }
        }
    }

    private func checkLoginStatus() {
        print("⏳ Starting checkLoginStatus.")
        print("🔄 hasPerformedInitialTokenRefresh: \(hasPerformedInitialTokenRefresh)")
               
        DispatchQueue.global().async {
            if !hasPerformedInitialTokenRefresh {
                print("🔄 Performing initial token refresh.")
                tokenManager.checkAndRefreshToken()
                hasPerformedInitialTokenRefresh = true
                print("✅ Initial token refresh completed.")
            } else {
                print("🕐 Checking if token needs refresh.")
                tokenManager.checkAndRefreshToken()
                print("✅ Token checked for refresh.")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                print("🚀 Attempting auto-login.")
                attemptAutoLogin()
            }
        }
    }

    private func attemptAutoLogin() {
        print("🔑 Starting attemptAutoLogin.")
        
        guard let savedUsername = KeychainWrapper.standard.string(forKey: "username"),
              let savedPassword = KeychainWrapper.standard.string(forKey: "password") else {
            print("❗ No saved credentials found. User will be logged out.")
            isLoggedIn = false
            isCheckingLogin = false
            return
        }

        print("✅ Saved credentials found - Username: \(savedUsername), Password: \(String(repeating: "*", count: savedPassword.count)).")
             isLoggedIn = true
             isCheckingLogin = false
             print("✅ Auto-login success. isLoggedIn: \(isLoggedIn), isCheckingLogin: \(isCheckingLogin)")
    }

    private func logOut() {
        print("🚪 Starting logOut process.")
        
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "refreshToken")
        KeychainWrapper.standard.removeObject(forKey: "username")
        KeychainWrapper.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "userStatus")
        UserDefaults.standard.removeObject(forKey: "userRole")
        UserDefaults.standard.removeObject(forKey: "tokenDate")
        
        print("✅ Logged out successfully. Keychain and UserDefaults cleared.")
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .environmentObject(AppChatState()) // Provide a mock AppChatState for previews
    }
}
