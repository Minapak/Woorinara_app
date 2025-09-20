//
//  Helper.swift
//  reqres_swiftui
//
//  Created by Girish Parate on 24/04/22.
//

import Foundation

struct Helpers {
    static func isValidId(text: String) -> Bool {
        // Check if ID is 5-25 characters long and only contains alphabets
        let idPattern = "^[A-Za-z]{5,25}$"
        return text.range(of: idPattern, options: .regularExpression) != nil
    }
    
    static func isValidPassword(text: String) -> Bool {
        // Check if password is 8-25 characters long and contains both letters and numbers
        let passwordPattern = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,25}$"
        return text.range(of: passwordPattern, options: .regularExpression) != nil
    }
}

