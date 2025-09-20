//
//  Constants.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 6.06.2023.
//

import Foundation
import SwiftUI


struct Constants {
     static let REWARDED_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/5224354917"
     static let INTERSTITIAL_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/1033173712"
     static let BANNER_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/6300978111"
    static let baseurl = "http://43.203.237.202:18080/"
    static let LoginUrl = "login/basic"
    static let ChatMessageUrl = "members"
    static let usersListUrl = "users"
    static let isLogedIn = "isLogedIn"
    static let isLoggedIn = "isLoggedIn"
    static let isFirstLogin = "isFirstLogin"
    static let hasCompletedARC = "hasCompletedARC"
    static let TERMS_OF_USE =  "https://site/terms_of_usage"
    static let PRIVACY_POLICY =  "https://site/privacy-policy"
    static let ABOUT =   "https://site/about"
    static let HELP = "https://site/help"
    static let RATE = "itms-apps://itunes.apple.com/app/id0000000000"
    static let isLocationPermissionGranted = "isLocationPermissionGranted"
    // 새로운 상수 추가
    
    static let REVENUE_CAT_API_KEY = "sk_vEbybyyWDnKUHddfgWyTHMRZbPgLE"
    static let ENTITLEMENTS_ID = "pro"
    static let ANNUAL_OFFER_ID = "$rc_annual"
    static let MONTHLY_OFFER_ID = "$rc_monthly"
    static let WEEKLY_OFFER_ID = "$rc_weekly"
    
    
    static let START_WEB_LINK = "summarizeWebPage||"
    static let DEFAULT_GPT_MODEL = "3.5"
    
    struct AppKeyBoardType {
        static let `default` = 0 // Default type for the current input method.

        static let asciiCapable = 1 // Displays a keyboard which can enter ASCII characters

        static let numbersAndPunctuation = 2 // Numbers and assorted punctuation.

        static let URL = 3 // A type optimized for URL entry (shows . / .com prominently).

        static let numberPad = 4 // A number pad with locale-appropriate digits (0-9, ۰-۹, ०-९, etc.). Suitable for PIN entry.

        static let phonePad = 5 // A phone pad (1-9, *, 0, #, with letters under the numbers).

        static let namePhonePad = 6 // A type optimized for entering a person's name or phone number.

        static let emailAddress = 7 // A type optimized for multiple email address entry (shows space @ . prominently).

        static let decimalPad = 8 // A number pad with a decimal point.

        static let twitter = 9 // A type optimized for twitter text entry (easy access to @ #)

        static let webSearch = 10 // A default keyboard type with URL-oriented addition (shows space . prominently).

        static let asciiCapableNumberPad = 11 // A number pad (0-9) that will always be ASCII digits.
    }

    struct Helpers {
        static func isVaildIdRegx(text:String) -> Bool {
            var isValidId = false
            let result = text.range(
                of: AppConst.emailPattern,
                options: .regularExpression
            )
            isValidId = (result != nil)
            return isValidId
        }
        
        static func isValidPassword(text:String) -> Bool {
            var isValidPassword = false
         
            if text.count >= 6 {
                isValidPassword = true
            } else {
                isValidPassword = false
            }
            return isValidPassword
        }
    }

    struct AppsFlyer {
        static let APPS_FLYER_DEV_KEY = "ProcessInfo.processInfo.environment["APPS_FLYER_KEY"] ?? """
        static let APPLE_APP_ID = "6450153759"
    }
    
    
    struct Prompts {
        static let REALISTIC = "rendered in a highly realistic style"
        static let CARTOON = "in a bright and colorful cartoon style"
        static let PENCIL_SKETCH = "as a detailed pencil sketch"
        static let OIL_PAINTING = "in the style of a classical oil painting"
        static let WATER_COLOR = "with a delicate watercolor effect"
        static let POP_ART = "in a vibrant pop art style"
        static let SURREALIST = "in a surrealistic style, with dream-like elements"
        static let PIXEL_ART = "as pixel art in a digital 8-bit style"
        static let NOUVEAU = "in an Art Nouveau style with elegant lines and floral patterns"
        static let ABSTRACT_ART = "in an abstract style with bold shapes and colors"
    }
    
    struct Preferences {
        static let LANGUAGE_CODE = "languageCode"
        static let API_KEY = "apiKey"
        static let GPT_MODEL = "gptModel"
        static let LANGUAGE_NAME = "languageName"
        static let SHARED_PREF_NAME = "mova_shared_pref"
        static let DARK_MODE = "darkMode"
        static let PRO_VERSION = "proVersion"
        static let FIRST_TIME = "firstTime"
        static let FREE_MESSAGE_COUNT = "freeMessageCount"
        static let FREE_MESSAGE_LAST_CHECKED_TIME = "freeMessageLastCheckedTime"
        static let FREE_MESSAGE_COUNT_DEFAULT = 50
        static let INCREASE_COUNT = 50
      }
    
    
    static let DEFAULT_AI = "You are an AI model that created by Coding With Love. if someone asked this, answer it."

 
 }

