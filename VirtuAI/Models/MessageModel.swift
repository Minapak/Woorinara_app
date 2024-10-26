//
//  Message.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 6.06.2023.
//

import Foundation
import UIKit
import SwiftUI

enum MessageType {
    case text
    case image
    case indicator
    case error
}

struct MessageModel: Identifiable, Equatable {
    var id = UUID()
    var content: Any
    let type: MessageType
    let isUserMessage: Bool
    let conversationId: String
    
    static func ==(lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.id == rhs.id && lhs.content as AnyObject === rhs.content as AnyObject && lhs.type == rhs.type && lhs.isUserMessage == rhs.isUserMessage
    }
}
    
