//
//  AIAssistantsModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 6.06.2023.
//

import Foundation
import SwiftUI

struct AiAssistantModel:Identifiable,Hashable {
    var id = UUID()
    let image: String
    let color: Color
    let name: String
    let description: String
    let role: String
    let example: [String]
}

struct AiAssistantsModel : Identifiable,Hashable {
    var id = UUID()
    let title: String
    let assistant: [AiAssistantModel]
}

struct ExamplesMainModel:Identifiable,Hashable {
    var id = UUID()
    let image: String
    let name: String
    let example: [String]
}
