//
//  TextFieldStyle.swift
//  ConversAI
//
//  Created by Murat ÖZTÜRK on 5.06.2023.
//

import Foundation
import SwiftUI


struct CustomTextFieldBackground: TextFieldStyle {
    @Binding var focused: Bool

    
    // Hidden function to conform to this protocol
    func _body(configuration: TextField<Self._Label>) -> some View {
        ZStack {

            VStack
            {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color.green_color, lineWidth: focused ? 1.5 : 0
                    ).frame(maxHeight: 150 )

                    
                   
            }.background(focused ? Color.green_color.opacity(0.2) : Color.gray_color ).cornerRadius(16)
            
    
            HStack {
                configuration
            }
            .padding(.leading)
            .foregroundColor(.text_color)
            
        }
    }
}
