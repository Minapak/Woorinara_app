import SwiftUI
import AlertToast
import Foundation
import SwiftKeychainWrapper


struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showingSuccessAlert: Bool = false

    @State private var isPasswordShow: Bool = false
    @State private var isValidId: Bool = true
    @State private var isValidPassword: Bool = false
    
    @AppStorage(Constants.isLogedIn) var isLogedIn: Bool = false
    @StateObject var viewModel = AlertViewModel()
    @StateObject var AuthviewModel = AuthenticationViewModel()
    @State private var isLoginSuccessful: Bool = false
    
    private let tokenManager = TokenManager()

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Solve your")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 0) {
                        Text("daily ")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        Text("challenges")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    Text("Settle in Korea, easily and quickly!")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.top, 15)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 30)
                
                VStack(spacing: 5) {
                    AppInputBox(
                        placeHoldr: "ID",
                        view: TextField("ID", text: $username),
                        keyboard: AppKeyBoardType.default,
                        state: isValidId
                    )
                    .onChange(of: username) { newValue in
                        withAnimation { isValidId = true }
                    }
                    AppInputBox(
                        placeHoldr: "Password",
                        passwordView: SecureField("Password", text: $password),
                        state: isValidPassword
                    )
                    .onChange(of: password) { newValue in
                        let result = Helpers.isValidPassword(text: password)
                        withAnimation { isValidPassword = result }
                    }
                }
                .padding(.top, 40)
                
                AppButton(text: "Login", clicked: {
                    if username.isEmpty || password.isEmpty {
                        viewModel.alertToast = CreateAlert().createErrorAlert(
                            title: "Email & Password are required",
                            subTitle: "please check error") as! AlertToast
                    } else {
                        loginAction()
                    }
                })
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .toast(isPresenting: $showingSuccessAlert) {
                    AlertToast(type: .complete(Color.green), title: "Login Successful!")
                }
                .onTapGesture { dismissKeyboard() }
                .padding(.top, 10)
                
                HStack {
                    NavigationLink(destination: SignUpView()) {
                        Text("Find Password").foregroundColor(.blue)
                    }
                    Spacer()
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up").foregroundColor(.blue)
                    }
                }
                .padding(.top,10)
                
                Spacer()
                
                VStack {
                    Text("Log in with SNS account").foregroundColor(.gray).opacity(0.7)
                }
                
                HStack {
                    Spacer()
                    Button(action: { AuthviewModel.googleLogin() }) {
                        Image("GoogleIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    Button(action: { AuthviewModel.appleLogin() }) {
                        Image("AppleIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    Spacer()
                }.padding(.bottom, 10)
            }
            .padding()
            .fullScreenCover(isPresented: $isLoginSuccessful) { ContentView() }
        }
    }
    
    func loginAction() {
        guard !username.isEmpty, !password.isEmpty else {
            alertMessage = "Both email and password are required"
            showAlert = true
            return
        }
        login(username: username, password: password)
    }

    func login(username: String, password: String) {
        guard let url = URL(string: "http://43.203.237.202:18080/login/basic") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json = ["username": username, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else { return }
        
        URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.alertMessage = "Client Error: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.alertMessage = "Invalid response from server."
                    self.showAlert = true
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    self.processSuccessResponse(data: data)
                    self.showingSuccessAlert = true
                    self.tokenManager.startTokenRefreshTimer() // 로그인 성공 시 토큰 갱신 타이머 시작
                } else {
                    self.processErrorResponse(data: data)
                }
            }
        }.resume()
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func processSuccessResponse(data: Data?) {
        guard let data = data,
              let token = try? JSONDecoder().decode(LoginToken.self, from: data) else {
            alertMessage = "Failed to decode response."
            showAlert = true
            return
        }
        KeychainWrapper.standard.set(username, forKey: "username") // username 저장
        KeychainWrapper.standard.set(password, forKey: "password") // password 저장
        KeychainWrapper.standard.set(token.accessToken, forKey: "accessToken")
        KeychainWrapper.standard.set(token.refreshToken, forKey: "refreshToken")
        UserDefaults.standard.set(token.status, forKey: "userStatus")
        UserDefaults.standard.set(token.role, forKey: "userRole")
        
        print("Access token and username saved.")
        isLoginSuccessful = true
    }

    private func processErrorResponse(data: Data?) {
        guard let data = data,
              let errorDetails = try? JSONDecoder().decode(ServerErrorDetails.self, from: data) else {
            alertMessage = "Error decoding error details."
            showAlert = true
            return
        }
        alertMessage = "Login failed: \(errorDetails.message)"
        showAlert = true
    }
}

class TokenManager {
    private let urlSession = URLSession.shared
    private let tokenRefreshURL = "http://43.203.237.202:18080/api/v1/token/issue"
    private let refreshThreshold: TimeInterval = 24 * 60 * 60 // 만료 24시간 전
    private var timer: Timer?

    func startTokenRefreshTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: refreshThreshold, repeats: true) { _ in
            self.checkAndRefreshToken()
        }
    }

    func checkAndRefreshToken() {
        guard let accessToken = KeychainWrapper.standard.string(forKey: "accessToken"),
              let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken"),
              let expirationDate = decodeExpirationDate(from: accessToken),
              expirationDate.timeIntervalSinceNow < 0 else {
            return
        }
        refreshAccessToken(refreshToken: refreshToken)
    }

    private func decodeExpirationDate(from accessToken: String) -> Date? {
        let tokenParts = accessToken.split(separator: ".")
        guard tokenParts.count > 1, let payloadData = Data(base64Encoded: String(tokenParts[1])) else {
            return nil
        }

        struct TokenPayload: Codable {
            let exp: TimeInterval
        }

        let decoder = JSONDecoder()
        guard let payload = try? decoder.decode(TokenPayload.self, from: payloadData) else {
            return nil
        }

        return Date(timeIntervalSince1970: payload.exp)
    }

    private func refreshAccessToken(refreshToken: String) {
        guard let url = URL(string: tokenRefreshURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let json = ["refreshToken": refreshToken]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("Failed to encode JSON for token refresh.")
            return
        }

        request.httpBody = jsonData

        urlSession.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil,
                  let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let newToken = try? JSONDecoder().decode(LoginToken.self, from: data) else {
                print("Token refresh failed.")
                return
            }
            KeychainWrapper.standard.set(newToken.accessToken, forKey: "accessToken")
            print("Token refreshed successfully.")
        }.resume()
    }
}


struct LoginToken: Codable {
    var username: String
    var accessToken: String
    var refreshToken: String
    var status: String
    var role: String
}

struct ServerErrorDetails: Codable {
    let message: String
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
