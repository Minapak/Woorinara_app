//
//  StartChatViewModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 4.06.2023.
//

import Foundation

class StartChatViewModel : ObservableObject{
  
    @Published var freeMessageCount: Int = UserDefaults.freeMessageCount

    private var firebaseViewModel = FirebaseViewModel()

    
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
}
