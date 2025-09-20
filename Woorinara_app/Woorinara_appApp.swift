//
//  Woorinara_appApp.swift
//  Woorinara_app
//
//  Created on 2024
//

import SwiftUI

@main
struct Woorinara_appApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
