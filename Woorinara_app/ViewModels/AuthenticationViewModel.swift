//
//  AuthenticationViewModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 29.11.2023.
//

import Foundation
import FirebaseAuth
import Firebase
import GoogleSignIn
import SwiftUI
import AuthenticationServices


class AuthenticationViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @Published var isLoading = false
    @Published var isLoadingApple = false
    @Published var showErrorToast = false
    private var firebaseViewModel = FirebaseViewModel()
    
    func googleLogin() {
        isLoading = true
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let scene =  UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController =  scene?.windows.first?.rootViewController
        else {
            isLoading = false
            showErrorToast = true
            fatalError("There is no root view controller!")
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) {  result, error in
            
            if let error = error {
                print(error.localizedDescription)
                self.isLoading = false
                self.showErrorToast = true
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                self.isLoading = false
                self.showErrorToast = true
                return
            }
            
            guard let user = result?.user,
                  let email = user.profile?.email else {
                self.isLoading = false
                self.showErrorToast = true
                return
            }
            
            
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.isLoading = false
                    self.showErrorToast = true
                    print(error.localizedDescription)
                }
                
                let newUser = User(email: email, isProUser: false, remainingMessageCount: Constants.Preferences.FREE_MESSAGE_COUNT_DEFAULT)
                
                // Save user using FirebaseViewModel
                self.firebaseViewModel.saveUser(user: newUser)
            }
        }
    }
    
    func appleLogin() {
        isLoadingApple = true
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func signOut() {
        isLoading = true
        
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            isLoading = false
        } catch {
            print(error.localizedDescription)
            showErrorToast = true
            isLoading = false
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.isLoadingApple = false
                self.showErrorToast = true
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: "")
            
            
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.isLoadingApple = false
                    self.showErrorToast = true
                    print(error.localizedDescription)
                } else {
                    // Handle successful authentication
                    
                    guard  let email = authResult?.user.email else {
                        self.isLoadingApple = false
                        self.showErrorToast = true
                        return
                    }
                    
                    
                    let newUser = User(email: email, isProUser: false, remainingMessageCount: Constants.Preferences.FREE_MESSAGE_COUNT_DEFAULT)
                    
                    // Save user using FirebaseViewModel
                    self.firebaseViewModel.saveUser(user: newUser)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.isLoadingApple = false
        self.showErrorToast = true
        print("Apple Sign-In error: \(error.localizedDescription)")
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding Method
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Find the current UIWindowScene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            fatalError("Unable to find a UIWindowScene.")
        }

        // Return the first window of the UIWindowScene
        guard let window = windowScene.windows.first else {
            fatalError("Unable to find a window.")
        }

        return window
    }

}



extension View {
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}
