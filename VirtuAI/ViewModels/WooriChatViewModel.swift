import Foundation
import Combine
import SwiftUI
import SQLite
import AVFoundation

class WooriChatViewModel: ObservableObject {
    // Using WooriChatAPI for chat functionalities
    let api = WooriChatAPI()
    @Published var messages = [MessageModel]() // This will hold MessageModel instances
    var role: String = ""
    var conversationId: String = ""
    var historyGPTModel: String = ""
    var stopStream = false
    @Published var isGenerating: Bool = false
    @Published var isGeneratingWithoutAnimation: Bool = false
    var cancellables = Set<AnyCancellable>()
    var sql = SQliteDatabase()
    var upgradeViewModel = UpgradeViewModel()

    var currectMessageAssistant: String = ""

    @AppStorage("textToSpeech") var textToSpeech: Bool = false
    let speechSynthesizer = AVSpeechSynthesizer()

    @AppStorage("language") private var language = LanguageManager.shared.selectedLanguage

    @Published var selectedGPT: GPTModelsEnum = UserDefaults.selectedGPT
    @Published var currentSelectedGPT: GPTModelsEnum = UserDefaults.selectedGPT
    @Published var freeMessageCount: Int = UserDefaults.freeMessageCount

    private var membersViewModel = MembersViewModel() // Replacing FirebaseViewModel with MembersViewModel

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

    func fetchMessages() {
        api.fetchWMessages { result in
            switch result {
            case .success(let fetchedMessages):
                DispatchQueue.main.async {
                    self.messages = fetchedMessages.map { WooriMessageData -> MessageModel in
                        MessageModel(content: WooriMessageData.content, type: .text, isUserMessage: WooriMessageData.sender != "BOT", conversationId: self.conversationId)
                    }
                }
            case .failure(let error):
                print("Error fetching messages: \(error.localizedDescription)")
            }
        }
    }

    func sendMessage(_ messageContent: String) {
        let newMessage = WooriMessageData(content: messageContent, sender: "User", createdAt: Date().description, quickReplyButtons: nil)
        api.addWooriMessage(newMessage)
        self.messages.append(MessageModel(content: messageContent, type: .text, isUserMessage: true, conversationId: self.conversationId))
    }
    func saveMessageToHistory(message : MessageModel){
        sql.addMessage(item: message)
    }
    
    // Functions for handling free message count and other interactions using MembersViewModel
    func getFreeMessageCount() {
        membersViewModel.getMembers { result in
            switch result {
            case .success(let members):
                self.freeMessageCount = members.annualIncome // Assuming annualIncome is used for demonstration
                UserDefaults.freeMessageCount = members.annualIncome
            case .failure(let error):
                print("Error retrieving user: \(error)")
            }
        }
    }

    func increaseFreeMessageCount() {
        let updatedIncome = membersViewModel.members?.annualIncome ?? Constants.Preferences.FREE_MESSAGE_COUNT_DEFAULT
        membersViewModel.members?.annualIncome = updatedIncome + Constants.Preferences.INCREASE_COUNT
        membersViewModel.saveMembers(members: membersViewModel.members!)
        UserDefaults.freeMessageCount += Constants.Preferences.INCREASE_COUNT
        freeMessageCount += Constants.Preferences.INCREASE_COUNT
    }

    func decreaseFreeMessageCount() {
        let updatedIncome = membersViewModel.members?.annualIncome ?? Constants.Preferences.FREE_MESSAGE_COUNT_DEFAULT
        membersViewModel.members?.annualIncome = max(updatedIncome - 1, 0)
        membersViewModel.saveMembers(members: membersViewModel.members!)
        UserDefaults.freeMessageCount -= 1
        freeMessageCount -= 1
    }
}
