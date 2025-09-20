//
//  ChatViewModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 6.06.2023.
//


import Foundation
import Combine
import SwiftUI
import SQLite
import AVFoundation

class ChatViewModel: ObservableObject {
    
    let api = OpenAIAPI()
    @Published var messages = [MessageModel]()
    var role: String = ""
    var conversationId: String = ""
    var historyGPTModel: String = ""
    var stopStream = false
    @Published var showAdsAndProVersion = false
    @Published var isGenerating: Bool = false
    @Published var isGeneratingWithoutAnimation: Bool = false
    var cancellables = Set<AnyCancellable>()
    var sql = SQliteDatabase()
    var upgradeViewModel = UpgradeViewModel()

    var currectMessageAssistant : String = ""
    
    @AppStorage("textToSpeech") var textToSpeech: Bool = false
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    
    @Published var selectedGPT: GPTModelsEnum = UserDefaults.selectedGPT
    @Published var currentSelectedGPT: GPTModelsEnum = UserDefaults.selectedGPT
    @Published var freeMessageCount: Int = UserDefaults.freeMessageCount
    private var firebaseViewModel = FirebaseViewModel()

    
    
     @Published var enteredForeground = true

       init() {
           if #available(iOS 13.0, *) {
               NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
           } else {
               NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
           }
       }

       @objc func willEnterForeground() {
           enteredForeground.toggle()
       }

       deinit {
           NotificationCenter.default.removeObserver(self)
       }
     

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

    
    
    func getSelectedGPT(){
        selectedGPT = UserDefaults.selectedGPT
        currentSelectedGPT = UserDefaults.selectedGPT
        print(upgradeViewModel.isSubscriptionActive)
        if !upgradeViewModel.isSubscriptionActive{
            currentSelectedGPT = GPTModelsEnum.gpt3_5
            selectedGPT = GPTModelsEnum.gpt3_5
            UserDefaults.selectedGPT = GPTModelsEnum.gpt3_5
        }
    }
    
    func setSelectedGPT(gpt: GPTModelsEnum){
         UserDefaults.selectedGPT = gpt
        selectedGPT = gpt
        currentSelectedGPT = gpt
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
    
    func removeHistory(){
        api.deleteHistoryList()
        DispatchQueue.main.async {
            self.messages = [MessageModel]()
        }
    }
    
    func saveMessageToHistory(message : MessageModel){
        sql.addMessage(item: message)
    }
    
    func getMessagesHistory(){
        
        if (self.conversationId != "")
        {
            selectedGPT = GPTModelsEnum(rawValue: historyGPTModel) ?? GPTModelsEnum.gpt3_5
            
            if !upgradeViewModel.isSubscriptionActive{
                currentSelectedGPT = GPTModelsEnum.gpt3_5
            }
            
            let messages = sql.getMessages(conversationIdCurrent : self.conversationId)
            var myHistoryList = [Message]()
            
            for message in messages {
                DispatchQueue.main.async {
                    
                    self.addMessage(message.content as! String, type: .text, isUserMessage: message.isUserMessage)
                    myHistoryList.append(Message(role: message.isUserMessage ? "user" : "assistant", content:message.content as! String))
                }
            }
            
            api.replaceHistoryList(with: myHistoryList)
        }
        

    }
    
    func stopSpeech()
    {
        if(self.speechSynthesizer.isSpeaking) {
            self.speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
    func stopGenerate()
    {
        stopSpeech();
        stopStream = true
        DispatchQueue.main.async {
            withAnimation {
                self.isGenerating = false
            }
            self.isGeneratingWithoutAnimation = false
        }
       
    }
    func regenerateAnswer() async{
        stopStream = false
        DispatchQueue.main.async {
            self.messages[self.messages.count - 1].content = "..."
            self.currectMessageAssistant = ""
        }
 
        do {
            DispatchQueue.main.async {
                withAnimation {
                    self.isGenerating = true
                }
                self.isGeneratingWithoutAnimation = true

            }
            
            let lastMessage =   sql.getLastHumanMessage(conversationIdCurrent: self.conversationId)
            // Fetch moderation asynchronously
            let result = try await api.fetchModeration(inputText: lastMessage?.content as! String)
                 
                 if result {
                     DispatchQueue.main.async {
                         self.messages[self.messages.count - 1].content = "Your message is flagged as inappropriate. Please try again."
                         self.currectMessageAssistant = "Your message is flagged as inappropriate. Please try again."
                     }
                     sql.updateLastBotMessage(conversationIdCurrent: self.conversationId, newContent: self.currectMessageAssistant)
                     DispatchQueue.main.async {
                         withAnimation {
                             self.isGenerating = false
                         }
                         self.isGeneratingWithoutAnimation = false

                     }
                     return
                 }
            
  
            
            
            let stream = try await api.sendMessageStream(text: lastMessage?.content as! String,
                                                         model: currentSelectedGPT == GPTModelsEnum.gpt3_5 ? "gpt-3.5-turbo-1106" : "gpt-4",
                                                         systemText: role,
                                                         temperature: 0.5)
            
            
            if !self.textToSpeech {
                DispatchQueue.main.async {
                    self.messages[self.messages.count - 1].content  = ""
                    self.currectMessageAssistant = ""
                }
            }
          
            var wordList : [String] = []
            for try await line in stream {
                
                if(self.textToSpeech) {
                    wordList.append(line)
                }
                
                DispatchQueue.main.async {
                    self.currectMessageAssistant = self.currectMessageAssistant + line

                    if(!self.textToSpeech) {
                        self.messages[self.messages.count - 1].content = self.messages[self.messages.count - 1].content as! String + line
                    }
                    
               
                }
                
                
                if stopStream {
                    break // Stop the stream if the flag is true
                }
            }
            
            if(self.textToSpeech) {
            
                DispatchQueue.main.async {
                    self.messages[self.messages.count - 1].content  = ""
                    self.currectMessageAssistant = ""
                }

                let dispatchGroup = DispatchGroup()
                var accumulatedDelay = 0.0
                let delayIncrement = 0.05

                for word in wordList {
                    if self.stopStream {
                           break
                       }
                    dispatchGroup.enter()
                    DispatchQueue.main.asyncAfter(deadline: .now() + accumulatedDelay) {
                        

                              if self.stopStream {
                                  dispatchGroup.leave()
                                  return // Exits the current async task without doing anything further
                              }
                        
                        if let lastMessage = self.messages.last, !lastMessage.isUserMessage {
                            var updatedContent = lastMessage.content as? String ?? ""
                            updatedContent += word
                            self.messages[self.messages.count - 1].content = updatedContent
                        }
                        dispatchGroup.leave()
                        

                    }
                    accumulatedDelay += delayIncrement

                }

                
                Task {
                    let utterance = AVSpeechUtterance(string: self.currectMessageAssistant)

                    utterance.pitchMultiplier = 1.0
                    utterance.rate = 0.5
              
                    utterance.voice = AVSpeechSynthesisVoice(language: self.language)
               
                    
                    self.speechSynthesizer.speak(utterance)
                }
                
                dispatchGroup.notify(queue: .main) {
                    
                    DispatchQueue.main.async {
                        withAnimation {
                            self.isGenerating = false
                        }
                        self.isGeneratingWithoutAnimation = false

                    }
                }
      
    
            }else
            {
                
                DispatchQueue.main.async {
                    withAnimation {
                        self.isGenerating = false
                    }
                    self.isGeneratingWithoutAnimation = false

                }
            }
            
            sql.updateLastBotMessage(conversationIdCurrent: self.conversationId, newContent: self.currectMessageAssistant)

        } catch {
            self.addMessage(error.localizedDescription, type: .error, isUserMessage: false)
        }
    }
    
    func getResponse(text: String) async{
        stopStream = false
        self.addMessage(text, type: .text, isUserMessage: true)
        self.addMessage("...", type: .text, isUserMessage: false)
        if self.conversationId == ""
        {
            self.conversationId = randomString(length: 5)
            
            let today = Date.now
            let formatter3 = DateFormatter()
            formatter3.dateFormat = "dd MMM yyyy - HH:mm"
            
            sql.addConversation(item: ConverstionsModel(conversationId: self.conversationId, title: text, createdAt: formatter3.string(from: today), gptModel: selectedGPT.rawValue))
            
        }
        
        
        sql.addMessage(item: MessageModel(content: text, type: .text, isUserMessage: true, conversationId: self.conversationId))
        
        do {
            DispatchQueue.main.async {
                withAnimation {
                    self.isGenerating = true
                }
                self.isGeneratingWithoutAnimation = true

            }
            
            // Fetch moderation asynchronously
            let result = try await api.fetchModeration(inputText: text)
                 
                 if result {
                     DispatchQueue.main.async {
                         self.messages[self.messages.count - 1].content = "Your message is flagged as inappropriate. Please try again."
                         self.currectMessageAssistant = "Your message is flagged as inappropriate. Please try again."
                     }
                     sql.addMessage(item: MessageModel(content: self.currectMessageAssistant, type: .text, isUserMessage: false, conversationId: self.conversationId))

                     DispatchQueue.main.async {
                         withAnimation {
                             self.isGenerating = false
                         }
                         self.isGeneratingWithoutAnimation = false

                     }
                     return
                 }
            
  
            
            
            let stream = try await api.sendMessageStream(text: text,
                                                         model: currentSelectedGPT == GPTModelsEnum.gpt3_5 ? "gpt-3.5-turbo-1106" : "gpt-4",
                                                         systemText: role,
                                                         temperature: 0.5)
            
            
            if !self.textToSpeech {
                DispatchQueue.main.async {
                    self.messages[self.messages.count - 1].content  = ""
                    self.currectMessageAssistant = ""
                }
            }
          
            var wordList : [String] = []
            for try await line in stream {
                
                if(self.textToSpeech) {
                    wordList.append(line)
                }
                
                DispatchQueue.main.async {
                    self.currectMessageAssistant = self.currectMessageAssistant + line

                    if(!self.textToSpeech) {
                        self.messages[self.messages.count - 1].content = self.messages[self.messages.count - 1].content as! String + line
                    }
                    
               
                }
                
                
                if stopStream {
                    break // Stop the stream if the flag is true
                }
            }
            
            if(self.textToSpeech) {
            
                DispatchQueue.main.async {
                    self.messages[self.messages.count - 1].content  = ""
                    self.currectMessageAssistant = ""
                }

                let dispatchGroup = DispatchGroup()
                var accumulatedDelay = 0.0
                let delayIncrement = 0.05

                for word in wordList {
                    if self.stopStream {
                           break
                       }
                    dispatchGroup.enter()
                    DispatchQueue.main.asyncAfter(deadline: .now() + accumulatedDelay) {
                        

                              if self.stopStream {
                                  dispatchGroup.leave()
                                  return // Exits the current async task without doing anything further
                              }
                        
                        if let lastMessage = self.messages.last, !lastMessage.isUserMessage {
                            var updatedContent = lastMessage.content as? String ?? ""
                            updatedContent += word
                            self.messages[self.messages.count - 1].content = updatedContent
                        }
                        dispatchGroup.leave()
                        

                    }
                    accumulatedDelay += delayIncrement

                }

                
                Task {
                    let utterance = AVSpeechUtterance(string: self.currectMessageAssistant)

                    utterance.pitchMultiplier = 1.0
                    utterance.rate = 0.5
              
                    utterance.voice = AVSpeechSynthesisVoice(language: self.language)
               
                    
                    self.speechSynthesizer.speak(utterance)
                }
                
                dispatchGroup.notify(queue: .main) {
                    
                    DispatchQueue.main.async {
                        withAnimation {
                            self.isGenerating = false
                        }
                        self.isGeneratingWithoutAnimation = false

                    }
                }
      
    
            }else
            {
                
                DispatchQueue.main.async {
                    withAnimation {
                        self.isGenerating = false
                    }
                    self.isGeneratingWithoutAnimation = false

                }
            }
            
            sql.addMessage(item: MessageModel(content: self.currectMessageAssistant, type: .text, isUserMessage: false, conversationId: self.conversationId))
            
//            DispatchQueue.main.async {
//                withAnimation {
//                    self.isGenerating = false
//                }
//            }
        } catch {
            self.addMessage(error.localizedDescription, type: .error, isUserMessage: false)
        }
    }
    
    private func addMessage(_ content: Any, type: MessageType, isUserMessage: Bool) {
        DispatchQueue.main.async {
            // if messages list is empty just addl new message
            guard let lastMessage = self.messages.last else {
                let message = MessageModel(content: content, type: type, isUserMessage: isUserMessage, conversationId: self.conversationId)
                self.messages.append(message)
                return
            }
            let message = MessageModel(content: content, type: type, isUserMessage: isUserMessage, conversationId: self.conversationId)
            // if last message is an indicator switch with new one
            if lastMessage.type == .indicator && !lastMessage.isUserMessage {
                self.messages[self.messages.count - 1] = message
            } else {
                // otherwise, add new message to the end of the list
                self.messages.append(message)
            }
            
            if self.messages.count > 100 {
                self.messages.removeFirst()
            }
        }
    }
    
}


func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}

