import SwiftUI
import FirebaseAuth
import SwiftKeychainWrapper

struct LogOutView: View {
    @State private var navigateToLogin = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack {
                Text("Are you sure you want to log out?")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding()

                Spacer()

                HStack(spacing: 20) {
                    Button(action: {
                        logOut()
                    }) {
                        Text("Log Out")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .alert(isPresented: $showErrorAlert) {
                        Alert(title: Text("Logout Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    }

                    Button(action: {
                        navigateToLogin = true
                    }) {
                        Text("Cancel")
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding()

                Spacer()
            }
            .padding()
            .fullScreenCover(isPresented: $navigateToLogin) {
                LoginView() // Ensure LoginView is implemented separately
            }
            .navigationTitle("Log Out") // Sets the title for navigation
            .navigationBarTitleDisplayMode(.inline) // Centers the title
        }
    }
    
    private func logOut() {
        do {
            try Auth.auth().signOut()
            KeychainWrapper.standard.removeObject(forKey: "accessToken")
            KeychainWrapper.standard.removeObject(forKey: "refreshToken")
            UserDefaults.standard.removeObject(forKey: "userStatus")
            UserDefaults.standard.removeObject(forKey: "userRole")
            print("Logged out successfully.")
            navigateToLogin = true
        } catch let signOutError as NSError {
            errorMessage = "Error signing out: \(signOutError.localizedDescription)"
            showErrorAlert = true
            print("Error signing out: \(signOutError)")
        }
    }
}

struct LogOutView_Previews: PreviewProvider {
    static var previews: some View {
        LogOutView()
    }
}
