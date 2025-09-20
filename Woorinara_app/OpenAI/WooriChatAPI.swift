//import SwiftUI
//import Foundation
//import SwiftKeychainWrapper
//import GPTEncoder
//import CommonCrypto
//import CryptoKit
//import Firebase
//// MARK: - API 모델들
//
//// API 모델들
//public struct WoorinaraMessage {
//    public var role: String
//    public var content: String
//    
//    public init(role: String, content: String) {
//        self.role = role
//        self.content = content
//    }
//}
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
//    let data: [WoorinaraMessageData]
//}
//
//class WoorinaraChatAPI: ObservableObject {
//    private let baseURL = "http://43.203.237.202:18080/api/v1/chatbot/messages"
//    private let urlSession = URLSession.shared
//    lazy var authToken: String = KeychainWrapper.standard.string(forKey: "accessToken") ?? "DefaultAccessToken"
//    @Published public private(set) var messages: [WoorinaraMessageData] = []
//    
//    private let urlString = "http://43.203.237.202:18080/api/v1/chatbot/messages"
//    private let gptEncoder = GPTEncoder()
//    public private(set) var WoorinarahistoryList = [WoorinaraMessage]()
//    
//    
//   
//
//    
//    private let jsonDecoder: JSONDecoder = {
//        let jsonDecoder = JSONDecoder()
//        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
//        return jsonDecoder
//    }()
//    
//    private var headers: [String: String] {
//        [
//            "Content-Type": "application/json",
//            "Authorization": "Bearer \(self.authToken)"
//        ]
//    }
//    
//    
//    private func WoorinarasystemMessage(content: String) -> WoorinaraMessage {
//        .init(role: "system", content: content)
//    }
//    
//    
//    private func WoorinaragenerateMessages(from text: String, systemText: String) -> [WoorinaraMessage] {
//        var messages = [WoorinarasystemMessage(content: systemText)] + WoorinarahistoryList + [WoorinaraMessage(role: "ROLE_MEMBER", content: text)]
//        if gptEncoder.encode(text: messages.content).count > 4096  {
//            _ = WoorinarahistoryList.removeFirst()
//            messages = WoorinaragenerateMessages(from: text, systemText: systemText)
//        }
//        return messages
//    }
//    
//    
//    
//    public func fetchWMessages(completion: @escaping (Result<[WoorinaraMessageData], Error>) -> Void) {
//        guard let url = URL(string: baseURL) else {
//            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
//        
//        let task = urlSession.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
//                return
//            }
//            
//            guard let data = data else {
//                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
//                return
//            }
//            
//            do {
//                let apiResponse = try JSONDecoder().decode(WoorinaraChatAPIResponse.self, from: data)
//                if apiResponse.status == 200 {
//                    DispatchQueue.main.async {
//                        self.messages = apiResponse.data
//                    }
//                    completion(.success(apiResponse.data))
//                } else {
//                    completion(.failure(NSError(domain: apiResponse.message, code: apiResponse.status, userInfo: nil)))
//                }
//            } catch {
//                completion(.failure(error))
//            }
//        }
//        
//        task.resume()
//    }
//    
//    public func clearHistory() {
//        DispatchQueue.main.async {
//            self.messages.removeAll()
//        }
//    }
//    
//    public func addWooriMessage(_ message: WoorinaraMessageData) {
//        DispatchQueue.main.async {
//            self.messages.append(message)
//        }
//    }
//    
//    func fetchModeration(inputText: String) async throws -> Bool {
//        guard let url = URL(string: "\(baseURL)/moderations") else {
//            print("Invalid URL")
//            return false
//        }
//        
//        let headers = [
//            "Content-Type": "application/json",
//            "Authorization": "Bearer \(authToken)"
//        ]
//        
//        let parameters = ["input": inputText]
//        
//        let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.allHTTPHeaderFields = headers
//        request.httpBody = jsonData
//        print(jsonData)
//        do {
//            let (data, _) = try await URLSession.shared.data(for: request)
//            
//            
//            
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("Response JSON string: \(jsonString)")
//            }
//            
//            
//            print(jsonData)
//            
//            let result = try JSONDecoder().decode(ModerationResult.self, from: data)
//            print(data)
//            // Check if any of the categories is flagged
//            if let flagged = result.results.first?.categories.values.contains(true) {
//                return flagged
//            }
//            
//            return false
//            
//        } catch {
//            
//            print("Error: \(error)")
//            throw error
//        }
//    }
//    
//    
//}
//    
//  
//
//struct ChatMessageView: View {
//    var message: WoorinaraMessageData
//  
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text(message.content)
//                .padding()
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(10)
//
//            ForEach(message.quickReplyButtons ?? [], id: \.label) { button in
//                Button(action: {
//               
//                    print("ActionValueeee: \(button.actionValue.value ?? "No value available")")
//                }) {
//                    VStack {
//                        Text(button.label)
//                            .fontWeight(.bold)
//                        Text(button.actionValue.text ?? "No specific action")  // 기본값 제공
//                            .font(.caption)
//                            .foregroundColor(.white)
//                    }
//                    .padding()
//                    .foregroundColor(.white)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//                }
//            }
//        }
//        .padding(.horizontal)
//        .padding(.top, 5)
//    }
//}
//
//struct ContentMView: View {
//    @ObservedObject var api = WooriChatAPI()
//   
//
//    var body: some View {
//        ScrollView {
//            ForEach(api.messages, id: \.createdAt) { message in
//                ChatMessageView(message: message)
//            }
//        }
//        .onAppear {
//            api.fetchWMessages { result in
//                switch result {
//                case .success(let messages):
//                    print("Messages loaded successfully")
//                case .failure(let error):
//                    print("Error loading messages: \(error)")
//                }
//            }
//        }
//    }
//}
//    
//
