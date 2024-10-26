//
//  ChipItem.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 7.06.2023.
//

import SwiftUI

struct ChipItem: View {
    var text : String
    var selected : Bool = false
    var onClick : () -> Void = {}
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    var body: some View {
        Button {
            onClick()
        } label: {
            VStack(alignment: .leading)
            {
                Text(text.localize(language)).modifier(UrbanistFont(.bold, size: 13)).multilineTextAlignment(.leading)
                    .foregroundColor(selected ? Color.white : Color.green_color)
                
            }.padding(.vertical,10).padding(.horizontal,15)
                .background( selected ?  Color.green_color : Color.background )
                .cornerRadius(90)
                .overlay(
                    RoundedRectangle(cornerRadius: 90)
                        .stroke(Color.green_color , lineWidth: 2)
                ).padding(3)
        }.buttonStyle(BounceButtonStyle())


    }
}

struct ChipItem_Previews: PreviewProvider {
    static var previews: some View {
        ChipItem(text: "Murat ÖZTÜRK",selected: false)
    }
}
