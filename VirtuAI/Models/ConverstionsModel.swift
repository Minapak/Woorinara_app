//
//  ConverstionsModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 8.06.2023.
//

import Foundation
import SwiftUI

struct ConverstionsModel: Identifiable {
    var id : Int = 0
    var conversationId : String
    let title: String
    let createdAt: String
    let gptModel: String
    var offset : CGFloat = 0
    var isSwiped :  Bool = false
}

