//
//  Appearance.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 9.06.2023.
//

import Foundation
import SwiftUI

class Appearance {

    var userInterfaceStyle: ColorScheme? = .dark

    func overrideDisplayMode(darkTheme : Bool) {
        var userInterfaceStyle: UIUserInterfaceStyle

        if darkTheme  {
            userInterfaceStyle = .light
        } else
        {
            userInterfaceStyle = .light
        }
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let window = windowScenes?.windows.first

        window?.overrideUserInterfaceStyle = userInterfaceStyle
    }
}
