//
//  UserModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 7.12.2023.
//


import Foundation

struct User: Codable, Identifiable {
    var id: String
    var email: String
    var isProUser: Bool
    var remainingMessageCount: Int

    
    // Computed property to convert the struct into a dictionary
      var dictionary: [String: Any] {
          return [
              "id": id,
              "email": email,
              "isProUser": isProUser,
              "remainingMessageCount": remainingMessageCount
          ]
      }
    
    init(id: String = "", email: String = "", isProUser: Bool = false, remainingMessageCount: Int = Constants.Preferences.FREE_MESSAGE_COUNT_DEFAULT) {
        self.id = id
        self.email = email
        self.isProUser = isProUser
        self.remainingMessageCount = remainingMessageCount
    }


}
