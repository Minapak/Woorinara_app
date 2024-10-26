//
//  SplashScreen.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 12.06.2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper
import AlertToast
struct SplashView: View {
    @State var isActive: Bool = false
    @State private var userLoggedIn = (Auth.auth().currentUser != nil)
    @State private var username: String = ""
       @State private var password: String = ""
       @State private var showAlert: Bool = false
       @State private var alertMessage: String = ""
       @State private var showingSuccessAlert: Bool = false
       @State private var isLoginSuccessful: Bool = false
       @State private var showingAlert = false
    @State private var isLoggedIn = false  // 로그인 상태 관리 변수
    @State private var isCheckingLogin = true  // 로그인 확인 중 상태
    
    var body: some View {
        VStack {
            if isCheckingLogin {
                // 로그인 확인 중 - 스플래시 이미지 표시
                ZStack {
                    Color.background
                        .edgesIgnoringSafeArea(.all)
                    Image("Splash")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        
                }
            } else if isLoggedIn {
                ContentView()  // 로그인 상태면 메인 뷰 표시
            } else {
                LoginView()  // 로그아웃 상태면 로그인 뷰 표시
            }
        }
        .onAppear {
            checkLoginStatus()  // 뷰가 나타날 때 로그인 상태 확인
        }
    }



    // 로그인 상태를 확인하는 함수
    private func checkLoginStatus() {
        // 로그인 상태 확인 로직, 딜레이를 추가하여 스플래시 화면이 잠시 보이도록 함
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let _ = KeychainWrapper.standard.string(forKey: "accessToken") {
                isLoggedIn = true  // accessToken이 존재하면 로그인 상태로 설정
                if let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") {
                    print("Access Token: \(accessToken)")
                } else {
                    print("Access Token not found in Keychain.")
                }
//
//                // 그런 다음, 필요 시 삭제
//                let success = KeychainWrapper.standard.removeObject(forKey: "accessToken")
//                if success {
//                    print("Successfully removed access token from Keychain.")
//                } else {
//                    print("Failed to remove access token from Keychain.")
//                }
            } else {
                isLoggedIn = false  // accessToken이 존재하지 않으면 로그아웃 상태로 설정
            }
            isCheckingLogin = false  // 로그인 확인 완료
        }
    }
}
 
    // 로그아웃 처리
      func logOut() {
          do {
              try Auth.auth().signOut()
              // 키체인 및 UserDefaults 데이터 제거
              KeychainWrapper.standard.removeObject(forKey: "accessToken")
              KeychainWrapper.standard.removeObject(forKey: "refreshToken")
              UserDefaults.standard.removeObject(forKey: "userStatus")
              UserDefaults.standard.removeObject(forKey: "userRole")
          
    
              print("Logged out successfully.")
          } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
          }
      }



struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
