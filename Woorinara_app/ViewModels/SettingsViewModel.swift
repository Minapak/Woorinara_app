//
//  SettingsViewModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 9.06.2023.
//


import SwiftUI

class SettingsViewModel: ObservableObject {
    
    @Published var isDarkTheme = Bool()
    var sql = SQliteDatabase()
    
    init()
    {
        isDarkTheme = UserDefaults.isDarkTheme
    }
    
    func saveDarkTheme(darkTheme: Bool)
    {
        UserDefaults.isDarkTheme = darkTheme
    }
    
}
