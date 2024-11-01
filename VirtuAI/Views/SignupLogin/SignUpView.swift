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
    
    // Error messages
    @State private var idErrorMessage: String = ""
    @State private var passwordErrorMessage: String = ""
    @State private var confirmPasswordErrorMessage: String = ""
    
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
            .padding(.top, 30)
            
            Spacer()
            
            VStack(spacing: 16) {
                // ID Field
                AppInputBox(
                    placeHoldr: "ID",
                    view: TextField("ID", text: $username),
                    keyboard: AppKeyBoardType.default,
                    state: isValidId
                )
                .modifier(ValidationModifier(isValid: isValidId, errorMessage: idErrorMessage, successMessage: "Valid ID"))
                .onChange(of: username) { _ in
                    validateId()
                }
                
                // Password Field
                AppInputBox(
                    placeHoldr: "Password",
                    passwordView: SecureField("Password", text: $password),
                    state: isValidPassword
                )
                .modifier(ValidationModifier(isValid: isValidPassword, errorMessage: passwordErrorMessage, successMessage: "Valid Password"))
                .onChange(of: password) { _ in
                    validatePassword()
                }
                
                // Confirm Password Field
                AppInputBox(
                    placeHoldr: "Confirm Password",
                    passwordView: SecureField("Confirm Password", text: $confirmPassword),
                    state: isValidConfirmPassword
                )
                .modifier(ValidationModifier(isValid: isValidConfirmPassword, errorMessage: confirmPasswordErrorMessage, successMessage: "Passwords match"))
                .onChange(of: confirmPassword) { _ in
                    validateConfirmPassword()
                }
            }
            
            // Create Account Button
            AppButton(text: "Create Account", clicked: {
                if validateAllFields() {
                    signUpAction()
                }
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .toast(isPresenting: $showingSuccessAlert) {
                AlertToast(type: .complete(Color.green), title: "Signup Successful!", subTitle: "Welcome!")
            }
            .padding(.top, 16)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Validation Methods
    
    private func validateId() {
        if username.count < 5 || username.count > 26 || !username.isAlphanumeric {
            isValidId = false
            idErrorMessage = "ID must be 5-26 characters and alphanumeric only"
        } else {
            isValidId = true
            idErrorMessage = ""
        }
    }
    
    private func validatePassword() {
        if password.count < 5 || password.count > 26 || !password.isAlphanumericWithLetterAndNumber {
            isValidPassword = false
            passwordErrorMessage = "Password must be 5-26 characters, with letters and numbers"
        } else {
            isValidPassword = true
            passwordErrorMessage = ""
        }
    }
    
    private func validateConfirmPassword() {
        if confirmPassword != password {
            isValidConfirmPassword = false
            confirmPasswordErrorMessage = "Passwords do not match"
        } else {
            isValidConfirmPassword = true
            confirmPasswordErrorMessage = ""
        }
    }
    
    private func validateAllFields() -> Bool {
        validateId()
        validatePassword()
        validateConfirmPassword()
        
        return isValidId && isValidPassword && isValidConfirmPassword
    }
    
    // MARK: - API Call
    
    private func signUpAction() {
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
                    self.showingSuccessAlert = true
                } else {
                    self.alertMessage = "Signup failed. Please try again."
                    self.showAlert = true
                }
            }
        }.resume()
    }
}

// MARK: - Validation Modifier for Red/Green Indicator

struct ValidationModifier: ViewModifier {
    var isValid: Bool
    var errorMessage: String
    var successMessage: String
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isValid ? Color.green : Color.red, lineWidth: 1)
                )
            
            Text(isValid ? successMessage : errorMessage)
                .font(.system(size: 12))
                .foregroundColor(isValid ? .green : .red)
                .padding(.leading, 4)
        }
    }
}

// MARK: - Extensions

extension String {
    var isAlphanumeric: Bool {
        let regex = "^[a-zA-Z0-9]*$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    var isAlphanumericWithLetterAndNumber: Bool {
        let regex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]*$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
}
