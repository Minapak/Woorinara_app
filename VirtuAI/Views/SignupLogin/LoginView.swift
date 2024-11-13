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
    @State private var isValidId: Bool = true
    @State private var isValidPassword: Bool = true
    @State private var idErrorMessage: String = ""
    @State private var passwordErrorMessage: String = ""
    
    @EnvironmentObject var appChatState: AppChatState
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @StateObject var viewModel = AlertViewModel()
    @StateObject var AuthviewModel = AuthenticationViewModel()
    @State private var isLoginSuccessful: Bool = false
    
    private let tokenManager = TokenManager.shared

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
                
                VStack(spacing: 15) {
                    // ID TextField with validation and "This ID does not exist" error handling
                    TextField("ID", text: $username)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).strokeBorder(isValidId ? Color.gray : Color.red, lineWidth: 1))
                        .onChange(of: username) { newValue in
                            isValidId = validateID(newValue)
                            idErrorMessage = isValidId ? "" : "Please enter between 5 and 26 characters (letters and/or numbers)"
                        }
                    
                    if !isValidId {
                        Text(idErrorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if !username.isEmpty && idErrorMessage == "This ID does not exist." {
                        Text("This ID does not exist.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Password SecureField with validation and "Incorrect password" error handling
                    SecureField("Password", text: $password)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).strokeBorder(isValidPassword ? Color.gray : Color.red, lineWidth: 1))
                        .onChange(of: password) { newValue in
                            isValidPassword = validatePassword(newValue)
                            passwordErrorMessage = isValidPassword ? "" : "Password must be 8-26 characters, including letters and numbers"
                        }
                    
                    if !isValidPassword {
                        Text(passwordErrorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if !password.isEmpty && passwordErrorMessage == "Incorrect password." {
                        Text("Incorrect password.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.top, 40)
                
                // Login Button
                Button(action: {
                    if isValidId && isValidPassword {
                        loginAction()
                    } else {
                        alertMessage = "Please ensure all fields are valid."
                        showAlert = true
                    }
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(16)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .toast(isPresenting: $showingSuccessAlert) {
                    AlertToast(type: .complete(Color.green), title: "Login Successful!")
                }
                .onTapGesture { dismissKeyboard() }
                .padding(.top, 10)
                
                HStack {
                    NavigationLink(destination: FindPWView()) {
                        Text("Find Password").foregroundColor(.blue)
                    }
                    Spacer()
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up").foregroundColor(.blue)
                    }
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding()
            .onAppear {
                tokenManager.checkAndRefreshTokenIfNeeded { success in
                    if !success {
                        print("Token refresh failed.")
                    }
                }
            }
        }
    }
    
    private func loginAction() {
        guard !username.isEmpty, !password.isEmpty else {
            alertMessage = "Both ID and password are required"
            showAlert = true
            return
        }
        
        login(username: username, password: password)
    }

    private func login(username: String, password: String) {
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
                
                // Handle specific server responses for non-existent ID and incorrect password
                if httpResponse.statusCode == 404 {
                    self.isValidId = false
                    self.idErrorMessage = "This ID does not exist."
                } else if httpResponse.statusCode == 401 {
                    self.isValidPassword = false
                    self.passwordErrorMessage = "Incorrect password."
                } else if httpResponse.statusCode == 200 {
                    self.processSuccessResponse(data: data)
                } else {
                    self.alertMessage = "Login failed."
                    self.showAlert = true
                }
            }
        }.resume()
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
        UserDefaults.standard.set(Date(), forKey: "tokenDate")
        
        appChatState.username = username
        appChatState.password = password
        appChatState.isUserLoggedIn = true
        isLoggedIn = true
        
        showingSuccessAlert = true
        print("Login successful, user details saved.")
    }
}

extension LoginView {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func validateID(_ id: String) -> Bool {
        let regex = "^[a-zA-Z0-9]{5,26}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: id)
    }

    private func validatePassword(_ password: String) -> Bool {
        let regex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,26}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: password)
    }
}

class TokenManager {
    static let shared = TokenManager()
    private let urlSession = URLSession.shared
    private let tokenRefreshURL = "http://43.203.237.202:18080/api/v1/token/issue"
    private let refreshThreshold: TimeInterval = 24 * 60 * 60
    
    func checkAndRefreshTokenIfNeeded(completion: @escaping (Bool) -> Void) {
        guard let lastLoginDate = UserDefaults.standard.object(forKey: "tokenDate") as? Date else {
            completion(false)
            return
        }

        if Date().timeIntervalSince(lastLoginDate) >= refreshThreshold {
            print("🔄 Token expired. Refreshing token.")
            refreshAccessToken(completion: completion)
        } else {
            print("✅ Token is still valid.")
            completion(true)
        }
    }

    func updateLastLoginDate() {
        UserDefaults.standard.set(Date(), forKey: "tokenDate")
    }

    private func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken"),
              let accessToken = KeychainWrapper.standard.string(forKey: "accessToken"),
              let url = URL(string: tokenRefreshURL) else {
            print("❗ Refresh token or URL missing.")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let json = ["refreshToken": refreshToken]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("❗ Failed to encode JSON for token refresh request.")
            completion(false)
            return
        }

        request.httpBody = jsonData

        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❗ Token refresh request failed: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("❌ Invalid response for token refresh request.")
                completion(false)
                return
            }
            
            guard let data = data,
                  let newToken = try? JSONDecoder().decode(LoginToken.self, from: data) else {
                print("❗ Token refresh response data decoding failed.")
                completion(false)
                return
            }
            
            KeychainWrapper.standard.set(newToken.accessToken, forKey: "accessToken")
            KeychainWrapper.standard.set(newToken.refreshToken, forKey: "refreshToken")
            self.updateLastLoginDate()
            print("✅ Token refreshed and saved to Keychain.")
            completion(true)
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
