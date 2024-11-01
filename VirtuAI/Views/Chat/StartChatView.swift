//
//  StartChatView.swift
//  Example
//
//  Created by 박은민 on 10/31/24.
//

import SwiftUI
import Foundation
import SwiftKeychainWrapper
import SafariServices
import CoreLocation
/*
이 코드는 iOS 앱에서 채팅 기능을 제공하는 뷰를 구현합니다.
 사용자가 메시지를 입력하고 전송하면 서버로부터의 응답을 가져와 화면에 표시하고,
 사용자에게 여러 Quick Reply 버튼을 통해 추가 선택지를 제공합니다.
특히, Quick Reply 버튼 중 일부는 네이버 지도 등 외부 링크를 열거나,
 특정 위치를 네이버 지도에서 탐색하도록 URL을 설정합니다.

주요 흐름:
1. **메시지 전송 및 서버 응답 처리**:
 사용자가 메시지를 입력하고 보내면 서버로 요청을 보내며,
 서버로부터 메시지 데이터를 받아 화면에 표시합니다.
 
2. **Quick Reply 버튼 사용**:
 서버가 응답으로 제공하는 Quick Reply 버튼을 사용하여,
 사용자가 다른 화면으로 이동하거나 외부 링크(네이버 지도 등)로
 이동할 수 있습니다.
 
3. **UI 요소 구성**:
 메시지 입력 필드, 전송 버튼,
 Quick Reply 버튼을 포함한 메시지 UI를 구성하며,
 메시지 전송 오류나 기타 알림을 위한 알림 창을 띄웁니다.

*/

// API 모델들 정의
public struct WMessage {
    public var role: String
    public var content: String
    
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

// QuickReply 버튼 정보 모델
struct QuickReplyButton: Codable, Equatable {
    let label: String
    let actionType: String
    var actionValue: ActionValue?
}

// ActionValue 모델: QuickReply의 동작을 정의
struct ActionValue: Codable, Equatable {
    var text: String?
    var value: String?
    var id: Int?
    var office: String?
    var address: String?
    var url: String? // 외부 URL로 연결할 경우 사용
    var latitude: Double?
    var longitude: Double?
    var office_eng: String?
    var address_eng: String?
    var phone_number: String?
}

// 서버 응답 데이터 모델
struct WooriMessageData: Codable, Equatable, Identifiable {
    let id = UUID()
    let content: String // 메시지 내용
    let sender: String // 발신자 정보 (사용자 or 봇)
    let createdAt: String // 메시지 생성 시간
    var quickReplyButtons: [QuickReplyButton]? // Quick Reply 버튼들
}

// 추가 서버 응답 세부 정보 모델
struct WooriMessageDetail: Codable, Equatable {
    let userMessage: String
    let userInfo: UserInfo
    let botMessage: String
    let action: String?
    let quickReplyButton: [QuickReplyButton]?
}

// GET 요청 응답 구조
struct ChatAPIGetResponse: Codable {
    let status: Int
    let message: String
    let data: [WooriMessageData]
}

// POST 요청 응답 구조
struct ChatAPIPostResponse: Codable {
    let status: Int
    let message: String
    let data: WooriMessageDetail
}

// 메시지 전송을 위한 RequestBody 모델
struct RequestBody: Codable {
    var preMessage: String
    var message: String
    var isButtonClicked: Bool
    var memberInfo: MemberInfo
}

// 사용자 위치 정보
struct MemberInfo: Codable {
    var latitude: String
    var longitude: String
}

// URL 확장: Identifiable 프로토콜 적용
extension URL: Identifiable {
    public var id: URL { self }
}

// WooriChatAPI 클래스: 메시지 전송 및 서버 데이터 가져오기 기능을 제공
class WooriChatAPI: ObservableObject {
    private let baseURL = "http://43.203.237.202:18080/api/v1/chatbot/messages" // API 엔드포인트
    private let urlSession = URLSession.shared
    lazy var authToken: String = KeychainWrapper.standard.string(forKey: "accessToken") ?? "DefaultAccessToken"
    
    @AppStorage("username") public var username: String = KeychainWrapper.standard.string(forKey: "username") ?? ""
    @Published public var messages: [WooriMessageData] = []

    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(self.authToken)"
        ]
    }

    // 서버로부터 메시지를 가져오는 함수 (GET 요청)
    public func fetchWMessages(completion: @escaping (Result<[WooriMessageData], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                print("GET Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid GET response")
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                print("GET: No data received")
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(ChatAPIGetResponse.self, from: data)
                if apiResponse.status == 200 {
                    DispatchQueue.main.async {
                        self.messages = apiResponse.data
                    }
                    completion(.success(self.messages))
                } else {
                    print("GET API Error: \(apiResponse.message)")
                    completion(.failure(NSError(domain: apiResponse.message, code: apiResponse.status, userInfo: nil)))
                }
            } catch {
                print("GET Decoding Error: \(error)")
                print("GET Data: \(String(data: data, encoding: .utf8) ?? "No Data")")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // 서버로 메시지를 전송하는 함수 (POST 요청)
    public func sendUserMessage(message: String, typingMessage: String? = nil, isButtonClicked: Bool = false, latitude: String, longitude: String, completion: @escaping (Result<WooriMessageDetail, Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTypingMessage = typingMessage?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalMessage = trimmedMessage + (trimmedTypingMessage.map { " \($0)" } ?? "")
        let previousMessage = messages.last?.content ?? "No previous message"
        
        let requestBody = RequestBody(
            preMessage: previousMessage,
            message: finalMessage,
            isButtonClicked: isButtonClicked,
            memberInfo: MemberInfo(latitude: latitude, longitude: longitude)
        )

        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            print("POST: Failed to encode JSON")
            completion(.failure(NSError(domain: "Failed to encode JSON", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData

        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                print("POST Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid POST response")
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                print("POST: No data received")
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(ChatAPIPostResponse.self, from: data)
                if apiResponse.status == 200 {
                    DispatchQueue.main.async {
                        let botMessageContent = apiResponse.data.botMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                        let botMessage = WooriMessageData(
                            content: botMessageContent,
                            sender: "BOT",
                            createdAt: Date().description,
                            quickReplyButtons: apiResponse.data.quickReplyButton
                        )
                        self.messages.append(botMessage)
                    }
                    completion(.success(apiResponse.data))
                } else {
                    print("POST API Error: \(apiResponse.message)")
                    completion(.failure(NSError(domain: apiResponse.message, code: apiResponse.status, userInfo: nil)))
                }
            } catch {
                print("POST Decoding Error: \(error)")
                print("POST Data: \(String(data: data, encoding: .utf8) ?? "No Data")")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}



// 사용자 인터페이스
struct StartChatView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var isFetchingLocation = false // 위치 정보 가져오는 중 여부
    @State private var navigateToTranslateView = false
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appChatState: AppChatState
    @StateObject private var WviewModel = WooriChatAPI()
    @AppStorage("language") private var language = LanguageManager.shared.selectedLanguage
    @State private var typingMessageCurrent: String = ""
    //요청값 위도/경도 고정값이 아니라
    @State var userLatitude: String = "37.5655981161314"
    @State var userLongitude: String = "126.9749287001093"
    @FocusState private var fieldIsFocused: Bool
    @Binding var typingMessage: String
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var safariViewURL: URL?
    @State private var isMessagesFetched = false // 메시지 로드 여부 확인 변수
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                AppBar(title: "", isMainPage: true)
                    .padding(.horizontal, 20)
                // TranslateView로의 NavigationLink
                NavigationLink(destination: TranslateView(), isActive: $navigateToTranslateView) {
                    EmptyView()
                }
                               
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(WviewModel.messages) { message in
                                MessageStartView(
                                    message: message,
                                    typingMessageCurrent: $typingMessageCurrent,
                                    currentUser: WviewModel.username,
                                    onQuickReplyTap: handleQuickReplyTap
                                )
                                .id(message.id)
                            }
                        }
                    }
                    .onAppear {
                        if !isMessagesFetched { // 메시지가 로드되지 않았다면 fetchWMessages 호출
                        WviewModel.fetchWMessages { result in
                            switch result {
                            case .success(let messages):
                                print("Messages loaded successfully: \(messages.count) messages.")
                            case .failure(let error):
                                alertMessage = "Error loading messages: \(error.localizedDescription)"
                                isShowingAlert = true
                            }
                        }
                            isMessagesFetched = true // 한 번 호출 후에는 true로 설정하여 다시 호출되지 않게 함
                                     }
                    }
                    .onChange(of: WviewModel.messages) { _ in
                        if let lastMessage = WviewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .padding(.horizontal, 3)
                
                Spacer()
                
                VStack(spacing: 0) {
                    HStack(alignment: .bottom, spacing: 15) {
                        ZStack(alignment: .trailing) {
                            TextField("Ask anything to Woori!", text: $typingMessageCurrent, axis: .vertical)
                                .focused($fieldIsFocused)
                                .lineLimit(5)
                                .padding(.trailing, 30)
                                .padding(15)
                                .background(fieldIsFocused ? Color.green_color.opacity(0.2) : Color.gray_color)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.green_color, lineWidth: fieldIsFocused ? 1.5 : 0)
                                )
                                .modifier(UrbanistFont(.semi_bold, size: 16))
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                            
                            Button {
                                sendMessage(typingMessageCurrent)
                                fieldIsFocused = false
                            } label: {
                                Image("Send")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 50, height: 50)
                            .background(Color.blue)
                            .cornerRadius(99)
                        }
                    }
                    .padding(.bottom, 20)
                    .background(Color.background)
                    .padding(.horizontal, 20)
                    .onChange(of: fieldIsFocused) { isFocused in
                        appState.hideBottomNav = isFocused
                    }
                    .onDisappear {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.bottom, 5)
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .fullScreenCover(item: $safariViewURL) { url in
            SafariView(url: url)
        }
    }
    
    private func handleQuickReplyTap(buttonLabel: String, actionValue: ActionValue?) {
        switch buttonLabel {
            case "Change Visa":
                sendMessage("Change Visa")
            case "Extend Visa":
                sendMessage("Extend Visa")
            case "Application Form":
                navigateToTranslateView = true
            case "Fill Application":
                navigateToTranslateView = true
            case "Hikorea Website":
                if let urlString = actionValue?.url, let url = URL(string: urlString) {
                    safariViewURL = url
                }
        case "Open Map":
            isFetchingLocation = true
            locationManager.startUpdatingLocation() // 실시간 위치 가져오기 시작
            
            // 1초 뒤에 위치 가져오기 완료 후 로그 출력 및 네이버 맵 열기 시도
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                locationManager.stopUpdatingLocation()
                isFetchingLocation = false
                
                // 현재 위치 정보 로그로 출력
                print("Latitude: \(locationManager.userLatitude), Longitude: \(locationManager.userLongitude)")

                if let address = actionValue?.address,
                   let office = actionValue?.office,
                   let destinationLatitude = actionValue?.latitude,
                   let destinationLongitude = actionValue?.longitude {
                    
                    // 출발지와 도착지 이름 정보 인코딩
                    let encodedStartName = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let encodedEndName = office.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    
                    // 네이버 지도 웹 URL 생성 (sname, dname에 한글 인코딩 적용)
                    let webMapURL = URL(string: "https://map.naver.com/v5/directions/-/141.39/\(destinationLatitude),\(destinationLongitude)?c=\(locationManager.userLatitude),\(locationManager.userLongitude),15,0,0,0,dh&dname=\(encodedEndName)&sname=\(encodedStartName)")!

                    // SafariView를 통해 네이버 지도 웹 페이지를 표시
                    safariViewURL = webMapURL
                } else {
                    alertMessage = "출발지와 도착지 정보가 없습니다."
                    isShowingAlert = true
                }
            }


            // 실시간 위치 업데이트 시작 (CoreLocation에서 위치 얻기 시작)
                  case "Office Location":
                      isFetchingLocation = true
                      locationManager.startUpdatingLocation() // 실시간 위치 가져오기 시작
                      sendMessage("Office Location", isButtonClicked: true)
                      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // 1초 후 위치 정보 사용
                          locationManager.stopUpdatingLocation()
                          isFetchingLocation = false
                          print("Latitude: \(locationManager.userLatitude), Longitude: \(locationManager.userLongitude)")
                          let encodedStart = locationManager.userLatitude.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                          let encodedEnd = locationManager.userLongitude.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

                      }

        default:
            break
        }
    }

    
    // 메시지 전송 함수
    private func sendMessage(_ message: String, isButtonClicked: Bool = false) {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        let messageRecord = WooriMessageData(content: trimmedMessage, sender: WviewModel.username, createdAt: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short), quickReplyButtons: nil)
        WviewModel.messages.append(messageRecord)
        
        WviewModel.sendUserMessage(message: trimmedMessage, typingMessage: typingMessage, isButtonClicked: isButtonClicked, latitude: userLatitude, longitude: userLongitude) { result in
            switch result {
            case .success:
                print("Message sent and response received.")
            case .failure(let error):
                alertMessage = "메시지 전송 실패: \(error.localizedDescription)"
                isShowingAlert = true
            }
        }
        typingMessageCurrent = ""
    }
}

// Extension to allow initialization of Color using hex values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}


struct MessageStartView: View {
    var message: WooriMessageData
    @Binding var typingMessageCurrent: String
    var currentUser: String = KeychainWrapper.standard.string(forKey: "username") ?? ""
    var onQuickReplyTap: (String, ActionValue?) -> Void
    
    var body: some View {
        HStack {
            if message.sender == currentUser {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(message.sender == currentUser ? Color.gray : Color(red: 0.25, green: 0.29, blue: 0.34)) // #414A57
                    .foregroundColor(.white)
                    .cornerRadius(14)
            } else {
                Image("chatLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                Text(message.content)
                    .padding()
                    .foregroundColor(.black)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(14)
                Spacer()
            }
        }
        .padding(.horizontal)
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(message.quickReplyButtons ?? [], id: \.label) { button in
                    Button(action: {
                        onQuickReplyTap(button.label, button.actionValue)
                    }) {
                        VStack {
                            Text(button.label)
                                .font(.system(size: 18, weight: .bold))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .cornerRadius(10)
                            Text(button.actionValue?.text ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .lineLimit(5) // Limit to 2 lines
                        }
                    }
                }
            }
        }
    }
}



// 외부 Safari 브라우저 뷰
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// Preview 설정
struct StartChatView_Previews: PreviewProvider {
    @State static var typingMessage: String = ""
        
    static var previews: some View {
        StartChatView(typingMessage: $typingMessage)
            .environmentObject(AppChatState())
    }
}
