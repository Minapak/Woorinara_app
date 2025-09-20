//
//  ColorExtension.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 3.06.2023.
//

import SwiftUI

extension Color {
    
    static let background = Color("Background")
    static let text_color = Color("TextColor")
    static let green_color = Color(UIColor(red: 0x3B / 255, green: 0x8A / 255, blue: 0xFF / 255, alpha: 1.0))
    static let inactive_input = Color("InactiveInput")
    static let gray_color = Color("Gray")
    static let message_background = Color("MessageBackground")
    static let code_background = Color("CodeBackgroud")
    static let card_border = Color("CardBorder")
    static let light_gray = Color("LightGray")
    static let red_shadow = Color("RedShadow")
    static let red_color = Color("Red")
    static let gray_shadow = Color("GrayShadow")
    static let thunder_green = Color("ThunderGreen")
    static let stars_purple = Color("StarsPurple")
    
    static let pastelBlue = Color(red: 174/255, green: 198/255, blue: 207/255)
    static let pastelPink = Color(red: 221/255, green: 160/255, blue: 221/255)
    static let pastelGreen = Color(red: 152/255, green: 251/255, blue: 152/255)
    static let pastelYellow = Color(red: 255/255, green: 219/255, blue: 88/255)
    static let pastelPurple = Color(red: 179/255, green: 158/255, blue: 181/255)
    static let pastelOrange = Color(red: 255/255, green: 179/255, blue: 71/255)
    static let pastelRed = Color(red: 255/255, green: 105/255, blue: 97/255)
    static let pastelGray = Color(red: 207/255, green: 207/255, blue: 196/255)
    static let pastelTurquoise = Color(red: 175/255, green: 238/255, blue: 238/255)
    static let pastelLavender = Color(red: 230/255, green: 230/255, blue: 250/255)
    static let pastelMint = Color(red: 152/255, green: 255/255, blue: 152/255)
    static let pastelSalmon = Color(red: 255/255, green: 160/255, blue: 122/255)
    static let pastelTeal = Color(red: 128/255, green: 206/255, blue: 225/255)
    static let pastelLilac = Color(red: 200/255, green: 162/255, blue: 200/255)
    static let pastelPeach = Color(red: 255/255, green: 218/255, blue: 185/255)
    static let pastelBeige = Color(red: 245/255, green: 245/255, blue: 220/255)
    static let pastelOlive = Color(red: 183/255, green: 206/255, blue: 99/255)
    static let pastelCoral = Color(red: 255/255, green: 127/255, blue: 80/255)
    static let pastelRose = Color(red: 255/255, green: 192/255, blue: 203/255)
    static let pastelAqua = Color(red: 173/255, green: 216/255, blue: 230/255)
    
    init(hex: String, alpha: Double = 1) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) { cString.remove(at: cString.startIndex) }
        
        let scanner = Scanner(string: cString)
        scanner.currentIndex = scanner.string.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(.sRGB, red: Double(r) / 0xff, green: Double(g) / 0xff, blue:  Double(b) / 0xff, opacity: alpha)
    }
}
