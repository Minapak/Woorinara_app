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
    @State private var isValidId: Bool = true
    @State private var isValidPassword: Bool = true
    @State private var isValidConfirmPassword: Bool = true
    @EnvironmentObject var viewModel: AlertViewModel
    @AppStorage(Constants.isLogedIn) var isLogedIn: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
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
                
                Text("Please verify and enter the code.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 30)
            
            Spacer()
            
            VStack(spacing: 16){
                // ID Input
                AppInputBox(
                    placeHoldr: "ID",
                    view: TextField("ID", text: $username)
                        .keyboardType(.default) // Use .keyboardType(.default) directly
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isValidId ? Color.gray : Color.red, lineWidth: 1)
                        ) as! TextField<Text>,
                    state: isValidId
                )
                .onChange(of: username) { newValue in
                    isValidId = validateID(username)
                }
                if !isValidId {
                    Text("Please enter between 5 and 26 characters")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Password Input
                AppInputBox(
                    placeHoldr: "Password",
                    passwordView: SecureField("Password", text: $password)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isValidPassword ? Color.gray : Color.red, lineWidth: 1)
                        ) as! SecureField<Text>,
                    state: isValidPassword
                )
                .onChange(of: password) { newValue in
                    isValidPassword = validatePassword(password)
                }
                
                // Confirm Password Input
                AppInputBox(
                    placeHoldr: "Confirm Password",
                    passwordView: SecureField("Confirm Password", text: $confirmPassword)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isValidConfirmPassword ? Color.gray : Color.red, lineWidth: 1)
                        ) as! SecureField<Text>,
                    state: isValidConfirmPassword
                )
                .onChange(of: confirmPassword) { newValue in
                    isValidConfirmPassword = confirmPassword == password
                }
                
                // Hints for Password Requirements
                if isValidId && isValidPassword && isValidConfirmPassword {
                    HStack {
                        Text("8-26 Characters")
                            .foregroundColor(.green)
                            .font(.system(size: 12))
                        Text("letters and numbers")
                            .foregroundColor(.green)
                            .font(.system(size: 12))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Sign Up Button
            AppButton(text: "Create Account", clicked: {
                if isValidId && isValidPassword && isValidConfirmPassword {
                    signUpAction()
                } else {
                    showAlert = true
                    alertMessage = "Please ensure all fields are valid."
                }
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .toast(isPresenting: $showingSuccessAlert) {
                AlertToast(type: .complete(Color.green), title: "Signup Successful!")
            }
            .onTapGesture {
                dismissKeyboard()
            }
            .padding(.top, 16)
            
            Spacer()
        }
        .padding()
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func signUpAction() {
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
        
        registerAccount(username: username, password: password)
    }
    
    private func registerAccount(username: String, password: String) {
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
    
    private func processSuccessResponse(data: Data?) {
        showingSuccessAlert = true
    }

    private func processErrorResponse(data: Data?) {
        alertMessage = "Signup failed: Please try again."
        showAlert = true
    }
    
    private func validateID(_ id: String) -> Bool {
        let regex = "^[a-zA-Z]{5,26}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: id)
    }
    
    private func validatePassword(_ password: String) -> Bool {
        let regex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,26}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: password)
    }
}

struct SignupToken: Codable {
    var username: String
    var nickname: String
    var email: String?
    var status: String
    var role: String
}

struct ServerSignupErrorDetails: Codable {
    let message: String
}
