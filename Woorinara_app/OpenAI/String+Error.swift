//
//  String+Error.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 28.11.2023.
//

import Foundation


extension String: CustomNSError {
    
    public var errorUserInfo: [String : Any] {
        [
            NSLocalizedDescriptionKey: self
        ]
    }
}
