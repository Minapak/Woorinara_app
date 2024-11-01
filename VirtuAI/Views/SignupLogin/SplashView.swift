import SwiftUI
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper
import AlertToast

struct SplashView: View {
    @EnvironmentObject var appChatState: AppChatState
    // Access as an environment object
    @State var isActive: Bool = false
    @State private var userLoggedIn = (Auth.auth().currentUser != nil)
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showingSuccessAlert: Bool = false
    @State private var isLoginSuccessful: Bool = false
    @State private var showingAlert = false
    @State private var isLoggedIn = false
    @State private var isCheckingLogin = true
    
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
            checkLoginStatus()
        }
    }

    private func checkLoginStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let _ = KeychainWrapper.standard.string(forKey: "accessToken") {
                isLoggedIn = true
            } else {
                isLoggedIn = false
            }
            isCheckingLogin = false
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .environmentObject(AppChatState()) // Provide a mock AppChatState for previews
    }
}
