//
//  SettingsView.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 4.06.2023.
//

import SwiftUI
import RevenueCat
import PopupView
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper
import AlertToast

struct SettingsView: View {
    @State var darkTheme : Bool = true
    @State var showingLogoutSheet : Bool = false
    @ObservedObject var viewModel = SettingsViewModel()
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    @State private var isPresented = false
    
    @AppStorage(Constants.Preferences.LANGUAGE_NAME)
    private var languageName = UserDefaults.selectedLanguageName
    
    @EnvironmentObject var upgradeViewModel: UpgradeViewModel
    @State var showSuccessToast = false
    @State var showErrorToast = false
    
    
    @StateObject var viewModelAuth = AuthenticationViewModel()

    var body: some View {
        
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                AppBar(title: "settings").padding(.horizontal,20)
                ScrollView(.vertical,showsIndicators: false){
                    VStack(alignment: .center,spacing: 20) {
                        
                        if !upgradeViewModel.isSubscriptionActive {
                            Button {
                                isPresented.toggle()
                            } label: {
                                HStack(){
                                    
                                    LottieView(animationName: "starLottie").frame(width: 55,height: 55).background(.white).cornerRadius(99, corners: .allCorners)
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        
                                        Text("upgrade_to_pro".localize(language)).modifier(UrbanistFont(.bold, size: 20)).foregroundColor(.white).multilineTextAlignment(.leading)
                                        
                                        Text("upgrade_to_pro_description".localize(language)).modifier(UrbanistFont(.semi_bold, size: 13)).foregroundColor(.white)
                                        
                                    }.frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Image("Right")
                                        .resizable().scaledToFill()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                    
                                }.padding(15).frame(maxWidth: .infinity, alignment: .leading)
                                    .shimmer(config: .init(tint: .white, highlight: .white.opacity(0.8),blur : 10))
                                    .background(Color.green_color).cornerRadius(20)
                                    .shadow(color: .black.opacity(0.2),radius: 6, x: 0, y: 6)
                                
                                
                                
                            }.buttonStyle(BounceButtonStyle())
                            
                        }
                        
                        
                        HStack(spacing: 0) {
                            Text("general".localize(language)).modifier(UrbanistFont(.regular, size: 12)).foregroundColor(.inactive_input)
                            
                            Rectangle()
                                .fill(Color.card_border)
                                .frame( height: 1)
                                .cornerRadius(10, corners: .allCorners)
                                .padding(10)
                            
                        }
                        
                        NavigationLink {
                            LanguagesView()
                        } label: {
                            HStack(spacing: 10) {
                                Image("MoreCircle")
                                    .resizable().scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor( .text_color)
                                
                                Text("language".localize(language)).modifier(UrbanistFont(.semi_bold, size: 15)).foregroundColor(.text_color).multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Text(languageName).modifier(UrbanistFont(.bold, size: 15)).foregroundColor(.text_color).multilineTextAlignment(.leading)
                                
                                Image("Right")
                                    .resizable().scaledToFill()
                                    .frame(width: 17, height: 17)
                                    .foregroundColor(.text_color)
                                
                            }
                        }
                        
                        
                        
                        HStack(spacing: 10) {
                            Image("Show")
                                .resizable().scaledToFill()
                                .frame(width: 30, height: 30)
                                .foregroundColor( .text_color)
                            
                            Text("dark_theme".localize(language)).modifier(UrbanistFont(.semi_bold, size: 15)).foregroundColor(.text_color).multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Toggle("", isOn: $viewModel.isDarkTheme).labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color.green_color))
                            
                        }
                        
                        HStack(spacing: 0) {
                            Text("purchase".localize(language)).modifier(UrbanistFont(.regular, size: 12)).foregroundColor(.inactive_input)
                            
                            Rectangle()
                                .fill(Color.card_border)
                                .frame( height: 1)
                                .cornerRadius(10, corners: .allCorners)
                                .padding(10)
                            
                        }
                        
                        
                        Button {
                            restorePurchase()
                        } label: {
                            HStack(spacing: 10) {
                                Image("Buy")
                                    .resizable().scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor( .text_color)
                                
                                Text("restore_purchase".localize(language)).modifier(UrbanistFont(.semi_bold, size: 15)).foregroundColor(.text_color).multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                
                                
                                Image("Right")
                                    .resizable().scaledToFill()
                                    .frame(width: 17, height: 17)
                                    .foregroundColor(.text_color)
                                
                            }
                        }
                        
                        
                        
                        HStack(spacing: 0) {
                            Text("about".localize(language)).modifier(UrbanistFont(.regular, size: 12)).foregroundColor(.inactive_input)
                            
                            Rectangle()
                                .fill(Color.card_border)
                                .frame( height: 1)
                                .cornerRadius(10, corners: .allCorners)
                                .padding(10)
                            
                        }
                        
                        Button {

                            
                            if let url = URL(string: Constants.RATE) {
                                UIApplication.shared.open(url)
                            }
                            
                        } label: {
                            HStack(spacing: 10) {
                                Image("StarVector")
                                    .resizable().scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor( .text_color)
                                
                                Text("rate_us".localize(language)).modifier(UrbanistFont(.semi_bold, size: 15)).foregroundColor(.text_color).multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Image("Right")
                                    .resizable().scaledToFill()
                                    .frame(width: 17, height: 17)
                                    .foregroundColor(.text_color)
                                
                            }
                        }
                        
                        Link(destination: URL(string: Constants.HELP)!) {
                            HStack(spacing: 10) {
                                Image("Paper")
                                    .resizable().scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor( .text_color)
                                
                                Text("help_center".localize(language)).modifier(UrbanistFont(.semi_bold, size: 15)).foregroundColor(.text_color).multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                
                                
                                Image("Right")
                                    .resizable().scaledToFill()
                                    .frame(width: 17, height: 17)
                                    .foregroundColor(.text_color)
                                
                            }
                        }
                        
                        Link(destination: URL(string: Constants.PRIVACY_POLICY)!) {
                            HStack(spacing: 10) {
                                Image("ShieldDone")
                                    .resizable().scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor( .text_color)
                                
                                Text("privacy_policy".localize(language)).modifier(UrbanistFont(.semi_bold, size: 15)).foregroundColor(.text_color).multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                
                                Image("Right")
                                    .resizable().scaledToFill()
                                    .frame(width: 17, height: 17)
                                    .foregroundColor(.text_color)
                                
                            }
                        }
                        
                        Link(destination: URL(string: Constants.ABOUT)!) {
                            HStack(spacing: 10) {
                                Image("InfoSquare")
                                    .resizable().scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor( .text_color)
                                
                                Text("about_us".localize(language)).modifier(UrbanistFont(.semi_bold, size: 15)).foregroundColor(.text_color).multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                
                                Image("Right")
                                    .resizable().scaledToFill()
                                    .frame(width: 17, height: 17)
                                    .foregroundColor(.text_color)
                                
                            }
                        }
                        
                        Button {
                            showingLogoutSheet.toggle()
                        } label: {
                            HStack(spacing: 10) {
                                Image("Logout")
                                    .resizable().scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor( .red_color)
                                
                                Text("logout".localize(language)).modifier(UrbanistFont(.semi_bold, size: 15)).foregroundColor(.red_color).multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                
                                Image("Right")
                                    .resizable().scaledToFill()
                                    .frame(width: 17, height: 17)
                                    .foregroundColor(.red_color)
                                
                            }
                        }
                        
                        
                    }.frame(maxHeight:.infinity).padding(.horizontal,20)
                }
            }.frame(maxHeight:.infinity)
                .onChange(of: viewModel.isDarkTheme, perform: { value in
                    withAnimation {
                        //                        Appearance().overrideDisplayMode(darkTheme: value)
                        viewModel.saveDarkTheme(darkTheme: value)
                    }
                })
            
            
        }
        .sheet(isPresented: $showingLogoutSheet) {
           VStack{
               Rectangle()
                   .fill(Color.card_border)
                   .frame(width : 60, height: 4)
                   .cornerRadius(10, corners: .allCorners)
                     .padding(10)
               
               Text("logout".localize(language)).modifier(UrbanistFont(.bold, size: 22)).multilineTextAlignment(.center)
                   .foregroundColor(Color.red_color).padding(.top, 4)
               
               Rectangle()
                   .fill(Color.card_border)
                   .frame( height: 2)
                   .cornerRadius(10, corners: .allCorners)
                     .padding(10)
               
               Text("are_you_sure_logout".localize(language)).modifier(UrbanistFont(.bold, size: 18)).multilineTextAlignment(.center)
                   .foregroundColor(Color.text_color).padding(.top, 4)
               
               Spacer().frame(height: 35)
               
               HStack(spacing: 15){
                   Button {
                       showingLogoutSheet.toggle()
                   } label: {
                       
                       Text("cancel".localize(language)).modifier(UrbanistFont(.bold, size: 16)).foregroundColor(.green_color) .frame(height: 55).frame(maxWidth: .infinity)
                           .background(Color.green_color.opacity(0.2)).cornerRadius(99)
                   }.buttonStyle(BounceButtonStyle())

           
                   
                   Button {
                       viewModelAuth.signOut()
                       logOut()
                   } label: {
                       
                       Text("yes_logout".localize(language)).modifier(UrbanistFont(.bold, size: 16)).foregroundColor(.white) .frame(height: 55).frame(maxWidth: .infinity)
                           .background(Color.green_color).cornerRadius(99)
                           .shadow(color: .black.opacity(0.2),radius: 6, x: 0, y: 6)
                   }.buttonStyle(BounceButtonStyle())
               }
               
           }.padding(15).frame(maxWidth: .infinity,maxHeight:.infinity ,  alignment: .topLeading)
           .presentationDetents([.height(280)])
           .presentationBackground {
               VStack{
                   Spacer()
                   
               }.padding(15).frame(maxWidth: .infinity,maxHeight:.infinity ,  alignment: .topLeading)
                   .background(   Color.light_gray )
                   .cornerRadius(50)
                   .overlay(
                       RoundedRectangle(cornerRadius: 50)
                           .stroke(Color.card_border, lineWidth: 2)
                   ).padding(3)
           }

       }
        .fullScreenCover(isPresented: $isPresented){
            UpgradeView(showSuccessToast: $showSuccessToast, showErrorToast: $showErrorToast)
        }
        .popup(isPresented: $viewModelAuth.showErrorToast) {
            HStack(alignment: .center){
                
                Text("cannot_logout".localize(language)).modifier(UrbanistFont(.semi_bold, size: 20)).multilineTextAlignment(.center)
                    .foregroundColor(Color.text_color)
                
            }.padding(EdgeInsets(top: 56, leading: 16, bottom: 16, trailing: 16))
                .frame(maxWidth: .infinity,alignment : .center).background(Color.red_color)
            
            
        } customize: {
            $0
                .type (.toast)
                .position(.top)
                .animation(.spring())
                .closeOnTapOutside(true)
                .dragToDismiss(true)
        }
        .popup(isPresented: $showSuccessToast) {
            HStack(alignment: .center){
                
                Text("welcome_to_pro_version".localize(language)).modifier(UrbanistFont(.semi_bold, size: 20)).multilineTextAlignment(.center)
                    .foregroundColor(Color.text_color)
                
            }.padding(EdgeInsets(top: 56, leading: 16, bottom: 16, trailing: 16))
                .frame(maxWidth: .infinity,alignment : .center).background(Color.green_color)
            
            
        } customize: {
            $0
                .type (.toast)
                .position(.top)
                .animation(.spring())
                .closeOnTapOutside(true)
                .dragToDismiss(true)
        }
        .popup(isPresented: $showErrorToast) {
            HStack(alignment: .center){
                
                Text("pro_version_not_purchased".localize(language)).modifier(UrbanistFont(.semi_bold, size: 20)).multilineTextAlignment(.center)
                    .foregroundColor(Color.text_color)
                
            }.padding(EdgeInsets(top: 56, leading: 16, bottom: 16, trailing: 16))
                .frame(maxWidth: .infinity,alignment : .center).background(Color.red_color)
            
            
        } customize: {
            $0
                .type (.toast)
                .position(.top)
                .animation(.spring())
                .closeOnTapOutside(true)
                .dragToDismiss(true)
        }
        
        
    }
    
    func restorePurchase()
    {
        upgradeViewModel.isLoading = true
        Purchases.shared.restorePurchases { (customerInfo, error) in
            
            upgradeViewModel.isLoading = false
            if customerInfo?.entitlements.all[Constants.ENTITLEMENTS_ID]?.isActive == true {
                upgradeViewModel.setThePurchaseStatus(isPro : true)
                showSuccessToast.toggle()
                
            }else
            {
                upgradeViewModel.setThePurchaseStatus(isPro : false)
                showErrorToast.toggle()
                
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
