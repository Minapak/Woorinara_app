//import SwiftUI
//import Foundation
//import SwiftKeychainWrapper
//import SwiftyChat
//import SwiftyChatMock
//// MARK: - API Models
//
//struct WoorinaraQuickReplyButton: Codable {
//    let label: String
//    let actionType: String
//    var actionValue: WoorinaraActionValue
//}
//
//struct WoorinaraActionValue: Codable {
//    var text: String?
//    var value: String?
//    var id: Int?
//    var office: String?
//    var address: String?
//    var latitude: Double?
//    var longitude: Double?
//    var office_eng: String?
//    var address_eng: String?
//    var phone_number: String?
//}
//
//struct WoorinaraMessageData: Codable {
//    let content: String
//    let sender: String
//    let createdAt: String
//    var quickReplyButtons: [WoorinaraQuickReplyButton]?
//}
//
//struct WoorinaraChatAPIResponse: Codable {
//    let status: Int
//    let message: String
//    let data: WoorinaraResponseData
//}
//
//struct WoorinaraResponseData: Codable {
//    var userMessage: String
//    var userInfo: WoorinaraUserInfo
//    var botMessage: String
//    var action: String?
//    var quickReplyButtons: [WoorinaraQuickReplyButton]?
//    
//    func toMessageData() -> WoorinaraMessageData {
//        return WoorinaraMessageData(
//            content: botMessage,
//            sender: "user",
//            createdAt: ISO8601DateFormatter().string(from: Date()),
//            quickReplyButtons: quickReplyButtons
//        )
//    }
//}
//
//struct WoorinaraUserInfo: Codable {
//    var latitude: String
//    var longitude: String
//    var memberId: String
//}
//
//// Observable object for handling chat interactions
//class WoorinaraChatViewAPI: ObservableObject {
//    private let baseURL = "http://43.203.237.202:18080/api/v1/chatbot/messages"
//    private let urlSession = URLSession.shared
//    lazy var authToken: String = KeychainWrapper.standard.string(forKey: "accessToken") ?? "DefaultAccessToken"
//    lazy var username: String = KeychainWrapper.standard.string(forKey: "username") ?? ""
//    @Published public var messages: [WoorinaraMessageData] = []
//    @Published var userMessages: [String] = []
//
//    public func fetchWMessages() {
//        guard let url = URL(string: baseURL) else { return }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data,
//                  let response = response as? HTTPURLResponse,
//                  response.statusCode == 200,
//                  let apiResponse = try? JSONDecoder().decode(WoorinaraChatAPIResponse.self, from: data) else {
//                print("Error fetching messages or decoding data")
//                return
//            }
//            
//            DispatchQueue.main.async {
//                self.messages.append(apiResponse.data.toMessageData())
//            }
//        }.resume()
//    }
//
//    func sendUserMessage(_ message: String, latitude: String, longitude: String, isButtonClicked: Bool) {
//        let messageData: [String: Any] = [
//            "preMessage": "Previous user message here",
//            "message": message,
//            "isButtonClicked": isButtonClicked,
//            "memberInfo": [
//                "latitude": latitude,
//                "longitude": longitude
//            ]
//        ]
//
//        guard let url = URL(string: baseURL),
//              let jsonData = try? JSONSerialization.data(withJSONObject: messageData) else {
//            print("Error: Invalid URL or data serialization")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                print("Network error: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                if let decodedResponse = try? JSONDecoder().decode(WoorinaraChatAPIResponse.self, from: data) {
//                    DispatchQueue.main.async {
//                        self.messages.append(decodedResponse.data.toMessageData())
//                    }
//                } else {
//                    print("Decoding response failed.")
//                }
//            } else {
//                print("HTTP Error: \(response.debugDescription)")
//            }
//        }.resume()
//    }
//
//}
//
//// View to display chat messages
//struct WoorinaraChatView: View {
//    @StateObject var chatAPI = WoorinaraChatViewAPI()
//    @State private var userInput: String = ""
//
//    var body: some View {
//        VStack {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 12) {
//                    ForEach(chatAPI.messages, id: \.createdAt) { message in
//                        // Align messages to the right if they are sent by the user, otherwise to the left
//                        HStack {
//                            if message.sender != "BOT" {
//                                Spacer() // Pushes user messages to the right
//                                Text(message.content)
//                                    .padding()
//                                    .background(Color.blue.opacity(0.5))
//                                    .cornerRadius(10)
//                                    .foregroundColor(.black)
//                                    .frame(maxWidth: 300, alignment: .trailing)
//                            } else {
//                                Text(message.content)
//                                    .padding()
//                                    .background(Color.gray.opacity(0.1))
//                                    .cornerRadius(10)
//                                    .foregroundColor(.black)
//                                    .frame(maxWidth: 300, alignment: .leading)
//                                Spacer() // Pushes bot messages to the left
//                            }
//                        }
//                    }
//                }
//                .padding(.horizontal)
//            }
//            .frame(maxWidth: .infinity)
//
//            HStack {
//                TextField("Type a message", text: $userInput)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .frame(minHeight: 44)
//                
//                Button("Send") {
//                    chatAPI.sendUserMessage(userInput, latitude: "37.5655981161314", longitude: "126.9749287001093", isButtonClicked: true)
//                    userInput = ""
//                }
//                .padding(.horizontal)
//                .frame(height: 44)
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//            }
//            .padding()
//        }
//    }
//}
//
//// Preview provider
//struct WoorinaraChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        WoorinaraChatView()
//    }
//}
