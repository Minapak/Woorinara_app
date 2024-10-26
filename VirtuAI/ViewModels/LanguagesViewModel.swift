//
//  LanguagesViewModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 9.06.2023.
//

import SwiftUI

class LanguagesViewModel: ObservableObject {
    
  
    
    func changeSelectedLanguage(name : String, code : String)
    {
        LanguageManager.shared.selectedLanguage = code
        UserDefaults.selectedLanguageName = name
        
    }
    
}
