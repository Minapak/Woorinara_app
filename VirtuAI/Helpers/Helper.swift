//
//  Helper.swift
//  reqres_swiftui
//
//  Created by Girish Parate on 24/04/22.
//

import Foundation

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
