import SwiftUI
import FloatingLabelTextFieldSwiftUI
import Alamofire
import AlertToast

struct SignUpView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordShow: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showingSuccessAlert: Bool = false
    // Validation
    @State private var isValidId: Bool = false
    @State private var isValidPassword: Bool = false
    @State private var isValidConfirmPassword: Bool = false
    @EnvironmentObject var viewModel: AlertViewModel
    
    @AppStorage(Constants.isLogedIn) var isLogedIn: Bool = false
    

    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            // Title and Subtitle Texts
            VStack(alignment: .leading, spacing: 10) {
                Text("Create")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                
                HStack(spacing: 0) {
                    Text("Your")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    Text("Account")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Text("Settle in Korea, easily and quickly!")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 30) // 위쪽에만 패딩 10 추가
            
            Spacer()
            VStack(spacing: 16){
                AppInputBox(
                   placeHoldr: "ID",
                    view: TextField("ID", text: $username),
                   keyboard: AppKeyBoardType.default,
                    state: isValidId
                )
                // On Change
                .onChange(of: username) { newValue in
                    let result = Helpers.isValidId(text: username)
                    withAnimation {
                        isValidId = result
                    }
                }
                AppInputBox(
                    placeHoldr: "Password",
                    passwordView: SecureField("Password", text: $password),
                    state: isValidPassword
                )
                // On change
                .onChange(of: password) { newValue in
                    let result = Helpers.isValidPassword(text: password)
                    withAnimation {
                        isValidPassword = result
                    }
                }
                AppInputBox(
                    placeHoldr: "Confirm Password",
                    passwordView: SecureField("Confirm Password", text: $confirmPassword),
                    state: isValidConfirmPassword
                )
                // On Change
                .onChange(of: confirmPassword) { newValue in
                    let result = Helpers.isValidPassword(text: confirmPassword)
                    withAnimation {
                        isValidConfirmPassword = result
                    }
                }
            }
            AppButton(text: "Create Account", clicked: {
                if(username.isEmpty || password.isEmpty){
                    viewModel.alertToast = AlertToast(displayMode: .banner(.slide), type: .error(.red), title: "ID & Password are required",subTitle: "please check error")
                }else{
                    signUpAction()
                    
                }
            }) .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .toast(isPresenting: $showingSuccessAlert) {
                AlertToast(type: .complete(Color.green), title: "Signup Successful!")
            }.onTapGesture {
                dismissKeyboard()
            }
                .padding(.top,16)
            Spacer()
        }
        .padding()

    }
                         
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
                         func signUpAction() {
                             guard !username.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
                                 alertMessage = "All fields are required"
                                 showAlert = true
                                 return
                             }
                             
                             guard password == confirmPassword else {
                                 alertMessage = "Passwords do not match"
                                 showAlert = true
                                 return
                             }
                             
                             // Example API call function
                             registerAccount(username: username, password: password)
                         }
                         
                         func registerAccount(username: String, password: String) {
                             guard let url = URL(string: "http://43.203.237.202:18080/api/v1/members") else { return }
                             var request = URLRequest(url: url)
                             request.httpMethod = "POST"
                             request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                             
                             let json = ["username": username, "password": password]
                             guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else { return }
                             
                             URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
                                 DispatchQueue.main.async {
                                     if let error = error {
                                         self.alertMessage = "Client Error: \(error.localizedDescription)"
                                       
                                         return
                                     }
                                     
                                     guard let httpResponse = response as? HTTPURLResponse else {
                                         self.alertMessage = "Invalid response from server."
                                       
                                         return
                                     }
                                     
                                     if httpResponse.statusCode == 200 {
                                         self.processSuccessResponse(data: data)
                                       
                                     } else {
                                         self.processErrorResponse(data: data)
                                     }
                                 }
                             }.resume()
                         }
    private func processSuccessResponse(data: Data?) {
        guard let data = data,
              let token = try? JSONDecoder().decode(SignupToken.self, from: data) else {
            alertMessage = "Failed to decode response."
           
            return
        }

        print("Access token and username saved.")
    }

    private func processErrorResponse(data: Data?) {
        guard let data = data,
              let errorDetails = try? JSONDecoder().decode(ServerErrorDetails.self, from: data) else {
            alertMessage = "Error decoding error details."
        
            return
        }
        alertMessage = "Login failed: \(errorDetails.message)"
      
    }
}

struct SignupToken: Codable {
    var username: String
    var nickname: String
    var email: String?
    var status: String
    var role: String
    
}
