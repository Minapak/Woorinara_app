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
    
    private let tokenManager = TokenManager.shared // 싱글톤 인스턴스를 사용

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
        
        KeychainWrapper.standard.set(username, forKey: "username")
        KeychainWrapper.standard.set(password, forKey: "password")
        KeychainWrapper.standard.set(token.accessToken, forKey: "accessToken")
        KeychainWrapper.standard.set(token.refreshToken, forKey: "refreshToken")
        UserDefaults.standard.set(token.status, forKey: "userStatus")
        UserDefaults.standard.set(token.role, forKey: "userRole")
        
        // 현재 날짜 저장
        UserDefaults.standard.set(Date(), forKey: "tokenDate")
        
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
    static let shared = TokenManager() // 싱글톤 인스턴스

    private let urlSession = URLSession.shared
    private let tokenRefreshURL = "http://43.203.237.202:18080/api/v1/token/issue"
    private let refreshThreshold: TimeInterval = 24 * 60 * 60 // 만료 24시간 전
    private var timer: Timer?
    private var lastTokenRefreshDate: Date? // 마지막 토큰 갱신 시간
    
    private init() {}

    func startTokenRefreshTimer() {
        print("🔄 Starting token refresh timer every midnight.")
             
             // 매일 자정에 토큰을 확인하고 필요한 경우 갱신하도록 설정
             timer = Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { [weak self] _ in
                 self?.checkAndRefreshToken()
             }
    }

    func checkAndRefreshToken() {
        print("🔍 Checking if token needs refresh based on date...")
             
             // 이전 갱신 날짜가 있는지 확인하고, 하루가 지나지 않았다면 갱신하지 않음
             if let lastRefreshDate = lastTokenRefreshDate,
                Calendar.current.isDateInToday(lastRefreshDate) {
                 print("✅ Token already refreshed today.")
                 return
             }

             // 토큰의 만료 날짜 확인
             guard let accessToken = KeychainWrapper.standard.string(forKey: "accessToken"),
                   let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken"),
                   let expirationDate = decodeExpirationDate(from: accessToken),
                   expirationDate < Date() else {
                 print("❌ No need to refresh token or token is still valid.")
                 return
             }
             
             print("🔄 Token needs refresh. Proceeding with refresh request.")
             
             // 토큰 갱신 수행
             refreshAccessToken(refreshToken: refreshToken)
             lastTokenRefreshDate = Date() // 갱신 날짜 업데이트
    }

    private func decodeExpirationDate(from accessToken: String) -> Date? {
        guard let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("❗ Failed to retrieve access token from Keychain.")
            return nil
        }
        
        let tokenParts = accessToken.split(separator: ".")
        guard tokenParts.count > 1 else {
            print("❗ Access token is not in the correct format.")
            return nil
        }
        
        var payloadString = String(tokenParts[1])
        while payloadString.count % 4 != 0 { // Base64 패딩 추가
            payloadString += "="
        }
        
        guard let payloadData = Data(base64Encoded: payloadString) else {
            print("❗ Failed to decode payload part of the token as Base64.")
            return nil
        }

        struct TokenPayload: Codable {
            let exp: TimeInterval
        }

        let decoder = JSONDecoder()
        guard let payload = try? decoder.decode(TokenPayload.self, from: payloadData) else {
            print("❗ Failed to decode JSON payload for expiration date.")
            return nil
        }

        let expirationDate = Date(timeIntervalSince1970: payload.exp)
        print("🕑 Token expiration date decoded: \(expirationDate)")
        return expirationDate
    }



    private func refreshAccessToken(refreshToken: String) {
        guard let url = URL(string: tokenRefreshURL) else {
            print("❗ Invalid token refresh URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken")
        
        let json = ["refreshToken": refreshToken]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("❗ Failed to encode JSON for token refresh request.")
            return
        }

        request.httpBody = jsonData

        print("🔄 Sending token refresh request to \(url.absoluteString)")

        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❗ Token refresh request failed with error: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("❌ Invalid response for token refresh request.")
                return
            }
            
            guard let data = data,
                  let newToken = try? JSONDecoder().decode(LoginToken.self, from: data) else {
                print("❗ Token refresh response data decoding failed.")
                return
            }
            
            KeychainWrapper.standard.set(newToken.accessToken, forKey: "accessToken")
            print("✅ Token refreshed successfully and saved to Keychain.")
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
