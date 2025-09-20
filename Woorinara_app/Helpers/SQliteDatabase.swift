//
//  SQliteDatabase.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 8.06.2023.
//


import SwiftUI
import SQLite

class SQliteDatabase {
    private let db: Connection
    
    init() {
        let fileManager = FileManager.default
        let documentsDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let databaseURL = documentsDirectory.appendingPathComponent("db.sqlite3")
        db = try! Connection(databaseURL.path)
        
        createConversationsTable()
        createMessagesTable()
    }
    
    
    private func createConversationsTable() {
        do {
            let conversations = Table("conversations")
            let id = Expression<Int>(value: "id")
            let conversationId = Expression<String>(value: "conversationId")
            let title = Expression<String>(value: "title")
            let createdAt = Expression<String>(value: "createdAt")
            let gptModel = Expression<String>(value: "gptModel")
            
            try db.run(conversations.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(conversationId)
                t.column(title)
                t.column(createdAt)
                t.column(gptModel)
            })
            
            
        } catch {
            print("createConversationsTable \(error)" )
        }
    }
    
    private func createMessagesTable() {
        do {
            let messages = Table("messages")
            let id = Expression<Int>(value: "id")
            let conversationId = Expression<String>(value: "conversationId")
            let content = Expression<String>(value: "content")
            let isUserMessage = Expression<Bool>(value: "isUserMessage")
            
            
            try db.run(messages.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(conversationId)
                t.column(content)
                t.column(isUserMessage)
            })
            
            
        } catch {
            print(error)
        }
    }
    
    func getConversations() -> [ConverstionsModel] {
        var list = [ConverstionsModel]()
        
        let conversations = Table("conversations")
        let conversationId = Expression<String>(value: "conversationId")
        let id = Expression<Int>(value: 1)
        let title = Expression<String>(value: "title")
        let createdAt = Expression<String>(value: "createdAt")
        let gptModel = Expression<String>(value: "gptModel")
        
        do {
            for conversation in try db.prepare(conversations) {
                let conversationModel = ConverstionsModel(id: conversation[id],conversationId : conversation[conversationId], title: conversation[title], createdAt: conversation[createdAt], gptModel: conversation[gptModel])
                list.append(conversationModel)
            }
        } catch {
            print(error)
        }
        
        return list
    }
    
    func getMessages(conversationIdCurrent : String) -> [MessageModel] {
        var list = [MessageModel]()
        
        let messages = Table("messages")
        _ = Expression<Int>(value: "id")
        let conversationId = Expression<String>(value: "conversationId")
        let content = Expression<String>(value: "content")
        let isUserMessage = Expression<Bool>(value: true)
        
        let messagesNew = messages.filter(conversationId == conversationIdCurrent)
        
        
        do {
            for message in try db.prepare(messagesNew) {
                let messagesModel = MessageModel(content: message[content], type: .text, isUserMessage: message[isUserMessage], conversationId: message[conversationId])
                list.append(messagesModel)
            }
        } catch {
            print(error)
        }
        
        return list
    }
    
    func addConversation(item: ConverstionsModel) {
        let conversations = Table("conversations")
        let conversationId = Expression<String>(value: "conversationId")
        let title = Expression<String>(value: "title")
        let createdAt = Expression<String>(value: "createdAt")
        let gptModel = Expression<String>(value: "gptModel")
        
        let insert = conversations.insert(conversationId <- item.conversationId, title <- item.title,createdAt <- item.createdAt,gptModel <- item.gptModel)
        
        do {
            try db.run(insert)
        } catch {
            print(error)
        }
    }
    func addMessage(item: MessageModel) {
        let messages = Table("messages")
        _ = Expression<UUID>(value: "id")
        let conversationId = Expression<String>(value: "conversationId")
        let content = Expression<String>(value: "content")
        let isUserMessage = Expression<Bool>(value: true)
        
        let insert = messages.insert(conversationId <- item.conversationId, content <- item.content as! String ,isUserMessage <- item.isUserMessage)
        do {
            try db.run(insert)
        } catch {
            print(error)
        }
    }
    
    func deleteConversation(conversationId: String) {
        let conversations = Table("conversations")
        let messages = Table("messages")
        let conversationIdSQL = Expression<String>(value: "conversationId")
        
        
        let conversationsNew = conversations.filter(conversationIdSQL == conversationId)
        let messagesNew = messages.filter(conversationIdSQL == conversationId)
        
        do {
            try db.run(conversationsNew.delete())
            try db.run(messagesNew.delete())
        } catch {
            print(error)
        }
        
    }
    
    func deleteAllConversations() {
        let conversations = Table("conversations")
        let messages = Table("messages")
        
        do {
            try db.run(conversations.delete())
            try db.run(messages.delete())
        } catch {
            print(error)
        }
        
    }
    
    func getLastHumanMessage(conversationIdCurrent: String) -> MessageModel? {
            let messages = Table("messages")
        let id = Expression<Int>(value:  0)
        let conversationId = Expression<String>(value: "conversationId")
        let content = Expression<String>(value:  "content")
        let isUserMessage = Expression<Bool>(value: true)

            // Filter messages for the current conversation and where isUserMessage is false
            let query = messages.filter(conversationId == conversationIdCurrent && isUserMessage == true)
                                .order(id.desc) // Order by 'id' in descending order
                                .limit(1) // Limit to only 1 result

            do {
                // Try to get the first (and only) message
                if let message = try db.pluck(query) {
                    return MessageModel(content: message[content], type: .text, isUserMessage: message[isUserMessage], conversationId: message[conversationId])
                }
            } catch {
                print("getLastBotMessage: \(error)")
            }

            return nil // Return nil if no message is found
        }
    
    
    func updateLastBotMessage(conversationIdCurrent: String, newContent: String) {
            let messages = Table("messages")
        let id = Expression<Int>(value: 0)
        let conversationId = Expression<String>(value: "conversationId")
        let content = Expression<String>(value: "content")
        let isUserMessage = Expression<Bool>(value: true)

            // Filter messages for the current conversation and where isUserMessage is false
            let query = messages.filter(conversationId == conversationIdCurrent && isUserMessage == false)
                                .order(id.desc)
                                .limit(1)

            do {
                if let message = try db.pluck(query) {
                    let messageId = message[id]
                    let update = messages.filter(id == messageId).update(content <- newContent)
                    try db.run(update)
                }
            } catch {
                print("updateLastBotMessage: \(error)")
            }
        }
}
