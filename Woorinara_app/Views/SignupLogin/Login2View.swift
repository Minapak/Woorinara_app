//
//  LoginView.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 29.11.2023.
//

import SwiftUI
import Firebase

struct Login2View: View {
    @State var isActive: Bool = false
    
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    
    @StateObject var viewModel = AuthenticationViewModel()
    
    var body: some View {
        ZStack {

            Color.background.edgesIgnoringSafeArea(.all)
            
            
            GeometryReader { geometry in
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center,spacing: 15) {
                        Image("AppVectorIcon")
                            .resizable().scaledToFill()
                            .frame(width: 180, height: 180)
                            .foregroundColor(.green_color)
                        
                        VStack(alignment: .center,spacing: 0) {

                            Text("app_name".localize(language)).modifier(UrbanistFont(.bold, size: 30))
                                .foregroundColor(Color.green_color).padding(.horizontal,10).padding(.vertical,1).background(Color.green_color.opacity(0.2)).cornerRadius(99, corners: .allCorners)
                            
                            
                            Text("welcome_description".localize(language)).modifier(UrbanistFont(.semi_bold, size: 17)).multilineTextAlignment(.center)
                                .foregroundColor(Color.text_color).padding(.top, 15)

                        }.padding(.top, 16)
   
                        Button {
                            viewModel.appleLogin()
                        } label: {
                            HStack
                            {
                                if viewModel.isLoadingApple {
                                    ProgressView()
                                        .scaleEffect(2, anchor: .center)
                                        .frame(width: 35, height: 35)
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.green_color))
                                }else
                                {
                                    Image("Apple")
                                        .resizable().scaledToFill()
                                        .frame(width: 35, height: 35)
                                }
                                Spacer().frame(width: 5)
                                Text("login_with_apple".localize(language)).modifier(UrbanistFont(.bold, size: 16)).foregroundColor(.text_color).shadow(color: .black.opacity(0.2),radius: 6, x: 0, y: 6).padding(5)
                            }.padding(10)
                                .frame(maxWidth:  .infinity)
                            .background(Color.background).cornerRadius(99)
                            .overlay(
                                RoundedRectangle(cornerRadius: 99)
                                    .stroke(Color.green_color, lineWidth: 2)
                            )
                     
                        }.buttonStyle(BounceButtonStyle()).padding(.top,25)
                                      
                        Button {
                            viewModel.googleLogin()
                        } label: {
                            HStack
                            {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .scaleEffect(2, anchor: .center)
                                        .frame(width: 35, height: 35)
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.green_color))
                                }else
                                {
                                    Image("Google")
                                        .resizable().scaledToFill()
                                        .frame(width: 35, height: 35)
                                }
                                Spacer().frame(width: 5)
                                Text("login_with_google".localize(language)).modifier(UrbanistFont(.bold, size: 16)).foregroundColor(.white).shadow(color: .black.opacity(0.2),radius: 6, x: 0, y: 6).padding(5)
                            }.padding(10).frame(maxWidth:  .infinity)
                            .background(Color.background).cornerRadius(99)
                            .overlay(
                                RoundedRectangle(cornerRadius: 99)
                                    .stroke(Color.green_color, lineWidth: 2)
                            )
                     
                        }.buttonStyle(BounceButtonStyle()).padding(.top,10)

      
                 
                    }.padding(.horizontal,20) .frame(width: geometry.size.width)
                        .frame(minHeight: geometry.size.height)
                    
                    
                    
                }.frame(maxHeight:.infinity,alignment: .center).onAppear {
                    UIScrollView.appearance().keyboardDismissMode = .interactive
                }
                
            }
            
            
        }.frame(maxHeight:.infinity)
            .popup(isPresented: $viewModel.showErrorToast) {
                HStack(alignment: .center){
                    
                    Text("cannot_login".localize(language)).modifier(UrbanistFont(.semi_bold, size: 20)).multilineTextAlignment(.center)
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
    
}



