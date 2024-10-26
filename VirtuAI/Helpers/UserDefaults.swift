//
//  UserDefaults.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 7.06.2023.
//

import Foundation

import SwiftUI

extension UserDefaults {
    
    static var myUserDefaults: UserDefaults {
        return UserDefaults.standard
    }
    
    static var freeMessageCount: Int {
        get {
            
            // Get the saved free message count and last checked time from UserDefaults.
            let savedCount = myUserDefaults.integer(forKey: Constants.Preferences.FREE_MESSAGE_COUNT)
            let lastCheckedTime = myUserDefaults.object(forKey: Constants.Preferences.FREE_MESSAGE_LAST_CHECKED_TIME) as? TimeInterval ?? 0

            // Check if the last checked time was yesterday or earlier.
            let currentTime = Date().timeIntervalSince1970
            let lastCheckedCalendar = Calendar.current
            let currentCalendar = Calendar.current
            if lastCheckedCalendar.component(.day, from: Date(timeIntervalSince1970: lastCheckedTime)) != currentCalendar.component(.day, from: Date(timeIntervalSince1970: currentTime)) ||
                lastCheckedCalendar.component(.year, from: Date(timeIntervalSince1970: lastCheckedTime)) != currentCalendar.component(.year, from: Date(timeIntervalSince1970: currentTime)) {
                // If last checked time was yesterday or earlier, reset the free message count to 3.
                myUserDefaults.set(Constants.Preferences.FREE_MESSAGE_COUNT_DEFAULT, forKey: Constants.Preferences.FREE_MESSAGE_COUNT)
                myUserDefaults.set(currentTime, forKey: Constants.Preferences.FREE_MESSAGE_LAST_CHECKED_TIME)
                return Constants.Preferences.FREE_MESSAGE_COUNT_DEFAULT
            }

            return savedCount
            
        }
        set {
            myUserDefaults.set(newValue, forKey: Constants.Preferences.FREE_MESSAGE_COUNT)
        }
    }
    
    static var isFirstTime: Bool {
        get {

            let savedCount = myUserDefaults.bool(forKey: Constants.Preferences.FIRST_TIME)
            return savedCount
            
        }
        set {
            myUserDefaults.set(newValue, forKey: Constants.Preferences.FIRST_TIME)

        }
    }
    
    static var selectedGPT: GPTModelsEnum {
        get {
            myUserDefaults.register(defaults: [Constants.Preferences.GPT_MODEL : GPTModelsEnum.gpt3_5.rawValue])

            guard let savedCount = myUserDefaults.string(forKey: Constants.Preferences.GPT_MODEL) else { return GPTModelsEnum(rawValue: GPTModelsEnum.gpt3_5.rawValue) ??  GPTModelsEnum.gpt3_5}
            return GPTModelsEnum(rawValue: savedCount) ?? GPTModelsEnum.gpt3_5
            
        }
        set {
            myUserDefaults.set(newValue.rawValue, forKey: Constants.Preferences.GPT_MODEL)

        }
    }
    
    static var isDarkTheme: Bool {
        get {
            myUserDefaults.register(defaults: [Constants.Preferences.DARK_MODE : true])

            let savedCount = myUserDefaults.bool(forKey: Constants.Preferences.DARK_MODE)
            return savedCount
            
        }
        set {
            myUserDefaults.set(newValue, forKey: Constants.Preferences.DARK_MODE)

        }
    }
    
    static var isProVersion: Bool {
        get {
            
            let savedCount = myUserDefaults.bool(forKey: Constants.Preferences.PRO_VERSION)
            return savedCount
            
        }
        set {
            myUserDefaults.set(newValue, forKey: Constants.Preferences.PRO_VERSION)
        }
    }
    
    static var selectedLanguageCode: String {
        get {
            
            guard let value = myUserDefaults.string(forKey: Constants.Preferences.LANGUAGE_CODE) else { return Locale.current.language.languageCode?.identifier ?? "en" }
            return value
            
        }
        set {
            myUserDefaults.set(newValue, forKey: Constants.Preferences.LANGUAGE_CODE)
        }
    }
    
    
    static var apiKey: String {
        get {

            guard let apiKey = myUserDefaults.string(forKey: Constants.Preferences.API_KEY) else { return "" }
            return apiKey
            
        }
        set {
            myUserDefaults.set(newValue, forKey: Constants.Preferences.API_KEY)

        }
    }
    
    
    static var selectedLanguageName: String {
        get {
            _ = Locale.current.localizedString(forIdentifier: Locale.current.identifier)
            let currentLanguage = Locale.current.localizedString(forLanguageCode: Locale.current.identifier)

            guard let value = myUserDefaults.string(forKey: Constants.Preferences.LANGUAGE_NAME) else { return currentLanguage ?? "English" }
            return value
            
        }
        set {
            myUserDefaults.set(newValue, forKey: Constants.Preferences.LANGUAGE_NAME)
        }
    }
}
