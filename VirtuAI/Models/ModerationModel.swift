//
//  ModerationModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 13.10.2023.
//

import Foundation



struct ModerationResult: Decodable {
    var results: [ModerationDetail]
}

struct ModerationDetail: Decodable {
    var flagged: Bool
    var categories: [String: Bool]
    var category_scores: [String: Double]
}
