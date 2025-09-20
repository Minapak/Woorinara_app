//
//  AppBar.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 4.06.2023.
//

import SwiftUI

struct AppBar: View {
    var imageName : String = "AppVectorIcon"
    var title : String = "app_name"
    var isMainPage : Bool = false
    var isChatPage : Bool = false
    var isDefault : Bool = true
    var isHistoryAppBar : Bool = false
    var onBack: () -> Void = { }
    var onSearch: () -> Void = { }
    var onDelete: () -> Void = { }
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    var body: some View {
        ZStack{
            if  !isChatPage
            {
                Text(title.localize(language)).modifier(UrbanistFont(.bold, size: 20)).multilineTextAlignment(.center)
                    .foregroundColor(Color.black).padding(.top, 4).frame(maxWidth:.infinity)
            }
         
            
            HStack{
                Button {
                    onBack()
                } label: {
                    Image("AppVectorIcon")
                        .resizable().scaledToFill()
                        .frame(width: 30, height: 30)
                        .foregroundColor(isDefault ? .green_color :  .text_color)
                }
                
                if isMainPage {
                    Text("WOORI").modifier(UrbanistFont(.extra_bold, size: 16))
                        .foregroundColor(Color.black)
                }
              
                if  isChatPage
                {
                    Text("WOORI").modifier(UrbanistFont(.bold, size: 20)).multilineTextAlignment(.leading)
                        .foregroundColor(Color.text_color).padding(.top, 4)
                }
                
                Spacer()
                
                if isHistoryAppBar
                {
                    HStack{
                        Button {
                            onSearch()
                        } label: {
                            Image("Search")
                                .resizable().scaledToFill()
                                .frame(width: 27, height: 27)
                                .foregroundColor(.text_color)
                        }
                        
                        Spacer().frame(width: 15)
                        
                        Button {
                            onDelete()
                        } label: {
                            Image("Delete")
                                .resizable().scaledToFill()
                                .frame(width: 27, height: 27)
                                .foregroundColor(.text_color)
                        }
                 
                    }
                }
                
            }
         
        }.frame(height: 55)
    }
}

struct AppBar_Previews: PreviewProvider {
    static var previews: some View {
        AppBar()
    }
}
