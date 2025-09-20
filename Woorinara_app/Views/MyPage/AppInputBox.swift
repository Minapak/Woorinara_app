//
//  AppInputBox.swift
//  reqres_swiftui
//
//  Created by Apple on 28/02/22.
//

import SwiftUI

struct AppInputBox: View {
    
    var leftIcon: String?
    var rightIcon: String?
    var placeHoldr: String
    
    var view: TextField<Text>?
    var passwordView: SecureField<Text>?
    var keyboard: Int?
    
    var state: Bool?
    
    var body: some View {
        VStack {
            HStack (spacing:8) {
                if leftIcon != nil {
                    Image(systemName:leftIcon!)
                        .inputIconStyle()
                        .padding(.leading,8)
                        .foregroundColor(Color.accentColor)
                        .animation(.easeIn(duration: 3), value:leftIcon ?? "")
                } else {
                    Spacer()
                }
                VStack {
                    if keyboard != nil{
                        view
                            .keyboardType(UIKeyboardType(rawValue: keyboard!) ?? .default)
                    } else if view != nil {
                        view
                    } else {
                        passwordView
                    }
                }
                if rightIcon != nil {
                    Image(systemName:rightIcon ?? "")
                        .inputIconStyle()
                        .padding(.trailing,8)
                        .foregroundColor( state == nil ? .accentColor : state ?? true ? .green : .red)
                        .animation(.easeIn(duration: 0.3), value:rightIcon ?? "")
                } else {
                    Spacer()
                }
            }
        }
        .background(
            Color.white.opacity(0.2)  // 배경색에 투명도 적용
                .frame(height: 48)    // 프레임의 높이 지정
                .cornerRadius(16)     // 모서리 둥글게 처리
                .overlay(
                    RoundedRectangle(cornerRadius: 16) // 둥근 사각형을 생성하고 모서리 반경 적용
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1) // 테두리 색상 및 두께 지정
                )
        )
        .frame(height: 55)
    }
}

struct AppInputBox_Previews: PreviewProvider {
    @State static var idText: String = "projectedValue"
    static var previews: some View {
        Group {
            AppInputBox(leftIcon: "heart.text.square",
                        rightIcon: "checkmark.circle.fill",
                        placeHoldr: "Placeholder",
                        view: TextField("Plasw", text: $idText))
                .previewLayout(.sizeThatFits)
                .padding()
            AppInputBox(leftIcon: "heart.text.square",
                        placeHoldr: "Placeholder")
                .previewLayout(.sizeThatFits)
                .padding()
            AppInputBox(rightIcon: "checkmark.circle.fill",
                        placeHoldr: "Placeholder")
                .previewLayout(.sizeThatFits)
                .padding()
            AppInputBox(placeHoldr: "Placeholder")
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
