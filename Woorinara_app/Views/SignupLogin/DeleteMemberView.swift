import SwiftUI
import SwiftKeychainWrapper

struct DeleteMemberView: View {
    @State private var navigateToLogin = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isAgreed = false
    @State private var showAgreementAlert = false
    
    private var authToken: String {
        KeychainWrapper.standard.string(forKey: "accessToken") ?? ""
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Delete Account")
                    .font(.title)
                    .bold()
                
                Text("Please make sure to check before deleting your account.")
                    .foregroundColor(.gray)
                    .padding(.bottom)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text("All information related to your account will be completely deleted after 30 days of account deletion.")
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    
                    Text("Precautions")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• After 7 days, you will not be able to log in or sign up with the same ID again.")
                        Text("• If you log in within 7 days, the account deletion will be canceled, and you can continue using the service.")
                        Text("• You can re-register with the same personal information after 30 days.")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Toggle(isOn: $isAgreed) {
                    Text("I have understood the above and agree to the account deletion.")
                        .font(.subheadline)
                }
                .toggleStyle(CheckboxToggleStyle())
                .padding(.vertical)

                HStack {
                    Button("Continue using") {
                        navigateToLogin = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                    
                    Button("Next") {
                        if isAgreed {
                            deleteAccount()
                        } else {
                            showAgreementAlert = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAgreed ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding()
            .fullScreenCover(isPresented: $navigateToLogin) {
                LoginView() // Ensure LoginView is implemented separately
            }
            .alert(isPresented: $showAgreementAlert) {
                Alert(title: Text("Agreement Required"), message: Text("Please agree to the terms before proceeding."), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func deleteAccount() {
        guard let url = URL(string: "http://43.203.237.202:18080/api/v1/members/delete") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to delete account: \(error.localizedDescription)"
                    self.showErrorAlert = true
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to delete account. Please try again."
                    self.showErrorAlert = true
                }
                return
            }
            
            DispatchQueue.main.async {
                self.logOut()
            }
        }
        
        task.resume()
    }

    private func logOut() {
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "refreshToken")
        UserDefaults.standard.removeObject(forKey: "userStatus")
        UserDefaults.standard.removeObject(forKey: "userRole")
        print("Logged out successfully.")
        navigateToLogin = true
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(configuration.isOn ? .blue : .gray)
                configuration.label
            }
        }
    }
}

struct DeleteMemberView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteMemberView()
    }
}
