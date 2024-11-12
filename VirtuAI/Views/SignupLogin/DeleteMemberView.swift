//
//  DeleteMemberView.swift
//  VirtuAI
//
//  Created by 박은민 on 11/11/24.
//

import SwiftUI
import SwiftKeychainWrapper

struct DeleteMemberView: View {
    @State private var navigateToLogin = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    private var authToken: String {
        // Keychain에 저장된 토큰을 가져옵니다.
        KeychainWrapper.standard.string(forKey: "accessToken") ?? ""
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Are you sure you want to delete your account?")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding()

                Spacer()

                HStack(spacing: 20) {
                    Button(action: {
                        deleteAccount()
                    }) {
                        Text("Delete Account")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .alert(isPresented: $showErrorAlert) {
                        Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
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
            .navigationTitle("Delete Account")
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

struct DeleteMemberView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteMemberView()
    }
}
