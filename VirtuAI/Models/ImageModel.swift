//
//  ImageModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 11.12.2023.
//

import Foundation

struct ImageStyle : Hashable {
    let text: String
    let imageName: String
    let prompt: String
}


struct Parameters: Codable {
    var model: String
    var n: Int
    var prompt: String
    var size: String
}


struct GeneratedImage: Codable {
    let created: Int
    let data: [DataImage]
}


struct DataImage: Codable {
    let url: String
}
