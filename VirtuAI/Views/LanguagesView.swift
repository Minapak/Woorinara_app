//
//  LanguagesView.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 9.06.2023.
//

import SwiftUI

struct LanguagesView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel = LanguagesViewModel()
    
    
    struct LanguageModel {
        let name: String
        let code: String
    }
    
    let languageList: [LanguageModel] = [
        LanguageModel(name: "English", code: "en"),
        LanguageModel(name: "Türkçe", code: "tr"),
        LanguageModel(name: "Español", code: "es"),
        LanguageModel(name: "Deutsch", code: "de"),
        LanguageModel(name: "Français", code: "fr"),
        LanguageModel(name: "Русский", code: "ru"),
        LanguageModel(name: "عربي", code: "ar"),
        LanguageModel(name: "辛斯", code: "zh-Hans"),
        LanguageModel(name: "हिन्दी", code: "hi"),
        LanguageModel(name: "বাংলা", code: "bn"),
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading) {
                    AppBar(imageName: "ArrowLeft", title: "language",isDefault: false, onBack:  {
                        self.presentationMode.wrappedValue.dismiss()
                    }).padding(.horizontal,20)
                    
                    
                    ScrollView(.vertical,showsIndicators: false){
                        VStack(alignment: .center,spacing: 20) {
                            
                            
                            ForEach(0..<languageList.count, id: \.self) { index in
                                let item = languageList[index]
                                Button {
                                    viewModel.changeSelectedLanguage(name : item.name, code : item.code)
                                } label: {
                                    VStack(alignment: .leading,spacing: 20){
                                        
                                        HStack
                                        {
                                            Text(item.name).modifier(UrbanistFont(.semi_bold, size: 20)).multilineTextAlignment(.leading)
                                                .foregroundColor(Color.text_color)
                                            Spacer()
                                            if LanguageManager.shared.selectedLanguage == item.code {
                                                Image("Done")
                                                    .resizable().scaledToFill()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.green_color)
                                            }
                                            
                                        }
                                        
                                        
                                        Rectangle()
                                            .fill(Color.card_border)
                                            .frame( height: 2)
                                            .cornerRadius(10, corners: .allCorners)
                                        
                                    }
                                    
                                    
                                    
                                }
                            }
                            
                        }.frame(maxHeight:.infinity).padding(.horizontal,20)
                    }
                    
                }.frame(maxHeight:.infinity).padding(.bottom,5)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct LanguagesView_Previews: PreviewProvider {
    static var previews: some View {
        LanguagesView()
    }
}
