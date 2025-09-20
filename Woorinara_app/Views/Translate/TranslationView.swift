import SwiftUI
import VComponents
import SwiftKeychainWrapper

struct TranslationView: View {
    // 화면 이동을 위한 상태 변수
    @State private var showTranslationView = false
    @State private var showAutoFillView = false
    @State private var showAlertInfo = false
     @State private var navigateToAFAutoView = false
     @State private var navigateToScanARCView = false
     @State private var navigateToScanPreARCView = false
     @State private var navigateToScanPrePassView = false
     @State private var navigateToMyInfoView = false
    @State private var navigateToTranslateView = false

    @State private var navigateToPassportInfoView = false
    @State private var navigateToARCInfoView = false
     @AppStorage("arcDataSaved") private var arcDataSaved: Bool = false
     @AppStorage("passportDataSaved") private var passportDataSaved: Bool = false
     @AppStorage("myInfoSaved") private var myInfoSaved: Bool = false
    // AppStorage
    @AppStorage("SavedarcData") private var savedARCData: Data?
    @AppStorage("SavedpassportData") private var savedPassportData: Data?
    @AppStorage("SavedmyInfoData") private var savedMyInfoData: Data?
    
    var body: some View {
           NavigationStack {
               ZStack {
                   Color.background.ignoresSafeArea(.all)

                   VStack(alignment: .center, spacing: 0) {
                       AppBar(title: "", isMainPage: true)
                           .padding(.horizontal)

                       VStack(alignment: .leading, spacing: 0) {
                           Text("Fill out your Application Form")
                               .font(.system(size: 24).bold())
                               .foregroundColor(.black)
                           Text("easy and quick!")
                               .font(.system(size: 24).bold())
                               .foregroundColor(.black)


                           Text("With just one click,")
                               .font(.system(size: 12))
                               .foregroundColor(.gray)
                           Text("you can translate and auto-fill your Application Form.")
                               .font(.system(size: 12))
                               .foregroundColor(.gray)
                       }

                      // Spacer()

                       Image("af")
                           .resizable()
                           .scaledToFit()
                           .frame(width: 200, height: 300)
                           .background(Color.gray.opacity(0.3))
                           .cornerRadius(8)
                           .padding()

                       Spacer()

                       HStack {
                           Button("Translation") {
                               handleTranslateNavigation()
                           }
                           .frame(width: 150, height: 50)
                           .font(.system(size: 16, weight: .bold))
                           .background(Color.blue)
                           .foregroundColor(.white)
                           .cornerRadius(16)

                           Button("Auto-Fill") {
                               handleAutoFillNavigation()
                       
                           }
                           .frame(width: 150, height: 50)
                           .font(.system(size: 16, weight: .bold))
                           .background(Color.blue)
                           .foregroundColor(.white)
                           .cornerRadius(16)
                       }
                   }
                   .padding(16)

                   if showAlertInfo {
                       ZStack {
                           Color.black.opacity(0.3).ignoresSafeArea()
                           AlertAutoView(isPresented: $showAlertInfo) {
                               handleScanNavigation()
                           }
                       }
                   }
               }
               .navigationDestination(isPresented: $navigateToTranslateView) {
                            TranslateView() // 여기를 새로운 TranslateView로 변경
                        }
                  
            .navigationDestination(isPresented: $navigateToScanARCView) {
                           ScanARCView()
                       }
            .navigationDestination(isPresented: $navigateToARCInfoView) {
                ARCInfoView()
            }
            .navigationDestination(isPresented: $navigateToPassportInfoView) {
                PassportInfoView()
            }
                       .navigationDestination(isPresented: $navigateToScanPreARCView) {
                           ScanPreARCView()
                       }
                       .navigationDestination(isPresented: $navigateToScanPrePassView) {
                           ScanPrePassView()
                       }
                       .navigationDestination(isPresented: $navigateToMyInfoView) {
                           MyInfoView()
                       }
                       .navigationDestination(isPresented: $navigateToAFAutoView) {
                           AFAutoView()
                       }
        }
    }
    
    private func handleAutoFillNavigation() {
        if let savedARCUserId = KeychainWrapper.standard.string(forKey: "arcUserId"),
           let savedPassportUserId = KeychainWrapper.standard.string(forKey: "passportUserId"),
           let currentUsername = KeychainWrapper.standard.string(forKey: "username"),
           (savedARCUserId == currentUsername || savedPassportUserId == currentUsername) {
            navigateToAFAutoView = true
        } else {
            print("❌ 사용자 검증 실패")
            showAlertInfo = true
        }
        
        if (savedARCData == nil) || (savedPassportData == nil) || (savedMyInfoData == nil) {
            showAlertInfo = true
        }

        else if (savedARCData != nil) && (savedPassportData != nil) && (savedMyInfoData != nil) {
            navigateToAFAutoView = true
        }
    }

    // Handles Scan Button Logic
    private func handleScanNavigation() {
        if  (savedARCData == nil) || (savedPassportData == nil) || (savedMyInfoData == nil){
            navigateToARCInfoView = true
        }

        else if (savedARCData != nil) && (savedPassportData != nil) && (savedMyInfoData != nil) {
            navigateToAFAutoView = true
        }
    }
    // Translation 버튼을 눌렀을 때의 네비게이션 처리
    private func handleTranslateNavigation() {
        if let savedARCUserId = KeychainWrapper.standard.string(forKey: "arcUserId"),
           let savedPassportUserId = KeychainWrapper.standard.string(forKey: "passportUserId"),
           let currentUsername = KeychainWrapper.standard.string(forKey: "username"),
           (savedARCUserId == currentUsername || savedPassportUserId == currentUsername) {
            navigateToTranslateView = true
        } else {
            print("❌ 사용자 검증 실패")
            showAlertInfo = true
         
        }
        if (savedARCData != nil) || (savedPassportData != nil) || (savedMyInfoData != nil) {
            // 데이터가 하나라도 있으면 TranslateView로 이동
            navigateToTranslateView = true
        } else {
          
            navigateToARCInfoView = true
        }
    }
}


struct AlertAutoView: View {
    @Binding var isPresented: Bool
    let onScan: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("No user information entered.")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("To use the auto-fill feature, please enter your information. Prepare to scan your ARC and passport.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            HStack(spacing: 16) {
                Button("Back") {
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(16)
                
                Button("Scan") {
                    isPresented = false
                    onScan()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ContentImageView: View {
    var body: some View {
        TranslationView()
    }
}

struct ImageApp: App {
    var body: some Scene {
        WindowGroup {
            ContentImageView()
        }
    }
}
