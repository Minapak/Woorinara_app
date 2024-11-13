import SwiftUI

struct SignUpView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showingSuccessAlert: Bool = false
    @State private var navigateToLogin: Bool = false // 로그인 페이지로 이동 트리거

    // Validation
    @State private var isValidId: Bool = true
    @State private var isValidPassword: Bool = true
    @State private var isValidConfirmPassword: Bool = true
    @EnvironmentObject var viewModel: AlertViewModel
    @AppStorage(Constants.isLogedIn) var isLogedIn: Bool = false
    
    var body: some View {
        ZStack {
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
                    TextField("ID", text: $username)
                        .padding(.horizontal)
                        .frame(height: 50)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isValidId ? Color.gray : Color.red)
                        )
                        .onChange(of: username) { _ in
                            isValidId = validateID(username)
                        }
                    
                    if !isValidId {
                        Text("Please enter between 5 and 26 characters")
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Password Input
                    SecureField("Password", text: $password)
                        .padding(.horizontal)
                        .frame(height: 50)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isValidPassword ? Color.gray : Color.red)
                        )
                        .onChange(of: password) { _ in
                            isValidPassword = validatePassword(password)
                        }
                    
                    // Confirm Password Input
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding(.horizontal)
                        .frame(height: 50)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isValidConfirmPassword ? Color.gray : Color.red)
                        )
                        .onChange(of: confirmPassword) { _ in
                            isValidConfirmPassword = confirmPassword == password
                        }
                    
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
                Button(action: {
                    if isValidId && isValidPassword && isValidConfirmPassword {
                        signUpAction()
                    } else {
                        showAlert = true
                        alertMessage = "Please ensure all fields are valid."
                    }
                }) {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(16)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .onTapGesture {
                    dismissKeyboard()
                }
                .padding(.top, 16)
                
                Spacer()
            }
            .padding()
            
            // Custom success alert at the top
            if showingSuccessAlert {
                VStack {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("Sign-up has been successfully completed")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    Spacer()
                }
                .padding(.top, 20)
                .transition(.move(edge: .top))
                .zIndex(1) // Display above other views
            }
            
            // Navigation link to LoginView
            NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingSuccessAlert)
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            self.showingSuccessAlert = false
                            self.navigateToLogin = true // LoginView로 네비게이션
                        }
                    }
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
