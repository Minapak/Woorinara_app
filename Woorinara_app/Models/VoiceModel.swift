//
//  VoiceModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 14.12.2023.
//

import Foundation

struct VoiceStyle : Hashable {
    let voiceName: String
    let image: String
    let voice: String
    let voiceFile: String
}


struct VoiceRequestBody: Codable {
    var model: String
    var input: String
    var voice: String
}
