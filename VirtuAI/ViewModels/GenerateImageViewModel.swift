//
//  AssistantsViewModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 7.06.2023.
//

import Foundation
import Combine
import SwiftUI
import SQLite

class GenerateImageViewModel: ObservableObject {
    
    let api = OpenAIAPI()
    
    @Published  var isGenerated: Bool = false
    @Published  var generatedImageURL: String = ""
    @Published  var selectedValue: String = "no_style"
    @Published  var selectedPrompt: String = ""
    @Published var isLoading: Bool = false
    
    @Published var showAdsAndProVersion = false
    @Published var isGenerating: Bool = false
    @Published var freeMessageCount: Int = UserDefaults.freeMessageCount
    private var firebaseViewModel = FirebaseViewModel()
    var upgradeViewModel = UpgradeViewModel()

    
    func getFreeMessageCount(){
        firebaseViewModel.getUser() { result in
            switch result {
            case .success(let user):
                
                self.freeMessageCount = user.remainingMessageCount
                UserDefaults.freeMessageCount = user.remainingMessageCount
                
            case .failure(let error):
                print("Error retrieving user: \(error)")
            }
        }
    }
    
    func decreaseFreeMessageCount(){
        UserDefaults.freeMessageCount -= 1
        freeMessageCount -= 1
        
        firebaseViewModel.updateCredit(remainingMessageCount: freeMessageCount)
        
    }
    
    
    func increaseFreeMessageCount(){
        UserDefaults.freeMessageCount += Constants.Preferences.INCREASE_COUNT
        freeMessageCount += Constants.Preferences.INCREASE_COUNT
        
        firebaseViewModel.updateCredit(remainingMessageCount: freeMessageCount)
        
    }
    
    
//    func generateImage(prompt: String) async{
//        
//        if !upgradeViewModel.isSubscriptionActive {
//            if  freeMessageCount > 0 {
//                self.decreaseFreeMessageCount()
//              
//            }else
//            {
//                DispatchQueue.main.async {
//                    withAnimation {
//                        self.showAdsAndProVersion = true
//                    }
//                }
//                return
//            }
//        }
//    
//           
//            
//            DispatchQueue.main.async {
//                self.isLoading = true
//            }
//            do {
//                let result = try await api.generateImage(prompt: "\(prompt) \(selectedPrompt)")
//
//                DispatchQueue.main.async {
//                    withAnimation {
//                        self.generatedImageURL = result.data.first?.url ?? ""
//                        self.isGenerated = true
//                        self.isLoading = false
//                    }
//                }
//                return
//
//            } catch {
//                DispatchQueue.main.async {
//                    withAnimation {
//                        self.isLoading = false
//                    }
//                }
//            }
//        
//        
//       
//    }
    
    
}
