//
//  AIAssistantItem.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 6.06.2023.
//

import SwiftUI

struct AssistantCard: View {
    var image : String
    var color : Color
    var name : String
    var description : String
    var role : String
    var examples : [String]
    var isVertical : Bool
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    var body: some View {
        
        NavigationLink(destination: LazyView(ChatView(name : name, role: role)), label: {
            VStack(alignment: .leading)
            {
                Image(image)
                    .resizable().scaledToFill()
                    .frame(width: 35, height: 35)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 16,style: .continuous).fill(color))
                
                Spacer().frame(height: 10)
                
                Text(name.localize(language)).modifier(UrbanistFont(.bold, size: 18)).multilineTextAlignment(.leading)
                    .foregroundColor(Color.text_color).padding(.top, 4)
                
                Spacer().frame(height: 10)
                
                Text(description.localize(language)).modifier(UrbanistFont(.medium, size: 12)).multilineTextAlignment(.leading)
                    .foregroundColor(Color.text_color)
                
            }.padding(15).frame(width: 150,height: isVertical ? 200 : 180, alignment: .topLeading).frame(maxWidth: isVertical ? .infinity : nil,  alignment: .topLeading)
                .background(   Color.light_gray )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.card_border, lineWidth: 2)
                ).padding(3)
        }).buttonStyle(BounceButtonStyle())

       
    }
}

struct AssistantCard_Previews: PreviewProvider {
    static var previews: some View {
        AssistantCard(image: "cake", color: .pastelRed, name: "AI Model", description: "Desc AI Model AI Model AI Model AI Model AI Model",role: "BOT", examples: [],isVertical: false)
    }
}
