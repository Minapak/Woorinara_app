import SwiftUI
import SwiftKeychainWrapper
import AlertToast

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showingSuccessAlert: Bool = false

    @State private var isPasswordShow: Bool = false
    @State private var isValidId: Bool = true
    @State private var isValidPassword : Bool = false
    
    @State private var showingAlert = false
    
    @AppStorage(Constants.isLogedIn) var isLogedIn: Bool = false
    
    @StateObject var viewModel = AlertViewModel()
    @StateObject var AuthviewModel = AuthenticationViewModel()
    @State private var isLoginSuccessful: Bool = false  // 로그인 성공 상태를 추적하는 변수
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // 제목 및 부제목 텍스트
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
            .padding(.top, 30) // 위쪽에만 패딩 추가
            
            VStack(spacing: 5){
                AppInputBox(
                    placeHoldr: "ID",
                    view: TextField("ID", text: $username),
                    keyboard: AppKeyBoardType.default,
                    state: isValidId
                )
                .onChange(of: username) { newValue in
                   
                    withAnimation {
                        isValidId = true
                        print(isValidId)
                    }
                }
                AppInputBox(
                    placeHoldr: "Password",
                    passwordView: SecureField("Password", text: $password),
                    state: isValidPassword
                )
                .onChange(of: password) { newValue in
                    let result = Helpers.isValidPassword(text: password)
                    withAnimation {
                        isValidPassword = result
                    }
                }
                
            }
            .padding(.top, 40) // 위쪽에만 패딩 추가
            
            AppButton(text: "Login", clicked: {
                if(username.isEmpty || password.isEmpty){
                    viewModel.alertToast = CreateAlert().createErrorAlert(
                        title: "Email & Password are required",
                        subTitle: "please check error") as! AlertToast
                } else {
                    loginAction()
                   
                }
            }) .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .toast(isPresenting: $showingSuccessAlert) {
                AlertToast(type: .complete(Color.green), title: "Login Successful!")
                
            }.onTapGesture {
                dismissKeyboard()
            }
            .padding(.top, 10) // 위쪽에만 패딩 추가
            
            HStack {
                NavigationLink(destination: SignUpView()) {
                    Text("Find Password")
                        .foregroundColor(.gray).opacity(0.7)
                }
                Spacer()
                NavigationLink(destination: SignUpView()) {
                    Text("Sign Up")
                        .foregroundColor(.gray).opacity(0.7)
                }
            }
            .padding(.top,10)
            
            Spacer() // 남은 공간을 채우는 스페이서 추가
            VStack {
                
                Text("Log in with SNS account")
                    .foregroundColor(.gray).opacity(0.7)
                
            }
            HStack {
                Spacer() // 왼쪽에 스페이서 추가
            
                Button(action: {
                      AuthviewModel.googleLogin()
                  }) {
                      Image("GoogleIcon") // 구글 로고 이미지
                          .resizable() // 이미지 크기 조절 가능하게 설정
                          .scaledToFit() // 비율을 유지하면서 프레임에 맞춤
                          .frame(width: 24, height: 24) // 이미지의 크기를 24x24로 지정
                  }
                Button(action: {
                      AuthviewModel.appleLogin()
                  }) {
                      Image("AppleIcon") // 애플 로고 이미지
                          .resizable() // 이미지 크기 조절 가능하게 설정
                          .scaledToFit() // 비율을 유지하면서 프레임에 맞춤
                          .frame(width: 24, height: 24) // 이미지의 크기를 24x24로 지정
                  }
                
                Spacer() // 오른쪽에 스페이서 추가
            }.padding(.bottom, 10)
        }
        .padding()
        .fullScreenCover(isPresented: $isLoginSuccessful) {  // 로그인 성공 시 ContentView를 풀스크린으로 표시
                   ContentView()
               }
    }
    
    
    
    func checkid() -> Bool {
        if(username.isValid(.userName)){
            return true
        } else {
            return false
        }
    }
    
    func checkPassword() -> Bool {
        if(password.count > 5){
            return true
        } else {
            return false
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
        KeychainWrapper.standard.set(token.accessToken, forKey: "accessToken")
        KeychainWrapper.standard.set(token.refreshToken, forKey: "refreshToken")
        KeychainWrapper.standard.set(token.username, forKey: "username")
        // 추가 정보 저장
        UserDefaults.standard.set(token.status, forKey: "userStatus")
        UserDefaults.standard.set(token.role, forKey: "userRole")
        
        print("Access token and username saved.")
        isLoginSuccessful = true  // 로그인 성공 처리
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

struct LoginToken: Codable {
    var username: String
    var accessToken: String
    var refreshToken: String
    var status: String
    var role: String

    var exp: String {
        struct TokenPayload: Codable {
            var exp: String
        }
        if let data = accessToken.split(separator: ".").map(String.init).dropFirst().first,
           let decodedData = Data(base64Encoded: data),
           let payload = try? JSONDecoder().decode(TokenPayload.self, from: decodedData) {
            return payload.exp
        }
        return ""
    }
}

struct ServerErrorDetails: Codable {
    let message: String
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
