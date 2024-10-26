//
//  File.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 4.06.2023.
//

import SwiftUI
import Combine

extension String {
    func localize(_ language: String) ->String {

        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        let bundle = Bundle(path: path!)

        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }}



class LanguageManager {
    static let shared = LanguageManager()

    private let selectedLanguageKey = "language"

    var selectedLanguage: String {
        get {
            return UserDefaults.standard.string(forKey: selectedLanguageKey) ?? Locale.current.language.languageCode?.identifier ?? "en" // Default language is English
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedLanguageKey)
            NotificationCenter.default.post(name: .languageDidChange, object: nil)
        }
    }
}

extension Notification.Name {
    static let languageDidChange = Notification.Name("LanguageDidChangeNotification")
    static let appearanceDidChange = Notification.Name("AppearanceDidChangeNotification")
}
