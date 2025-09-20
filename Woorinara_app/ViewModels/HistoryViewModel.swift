//
//  HistoeyViewModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 8.06.2023.
//


import SwiftUI
import SQLite

class HistoryViewModel: ObservableObject {
    
    @Published var conversations = [ConverstionsModel]()
    var sql = SQliteDatabase()

    func getConversations(){
        print( sql.getConversations())
        conversations =   sql.getConversations()
 
    }
    func deleteAllConversations(){
        conversations.removeAll()
        sql.deleteAllConversations()
    }
    func deleteHistoryItem(conversationId : String){
        DispatchQueue.main.async {
            self.sql.deleteConversation(conversationId: conversationId)
            withAnimation {
                self.conversations.removeAll { (item) -> Bool in
                return conversationId == item.conversationId
                   }
            }
           
        
        }
    }
   
}
