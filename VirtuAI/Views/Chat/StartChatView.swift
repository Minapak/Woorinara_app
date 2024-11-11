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
import Combine
import CoreLocationUI
import MapKit
import UIKit
import WebKit
import iActivityIndicator
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
    var address: String?
    var url: String? // 외부 URL로 연결할 경우 사용
    var latitude: Double?
    var longitude: Double?
    var address_eng: String?
    var office: String?
    var office_eng: String?
    var phone_number: String?
    var name: String?
    var type: String?
    var name_eng: String?
    var detailed_location: String?
    var detailed_location_eng: String?
    
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
    var latitude: Double
    var longitude: Double
}

// URL 확장: Identifiable 프로토콜 적용
extension URL: Identifiable {
    public var id: URL { self }
}

// WooriChatAPI 클래스: 메시지 전송 및 서버 데이터 가져오기 기능을 제공
class WooriChatAPI: ObservableObject {
    private let baseURL = "http://43.203.237.202:18080/api/v1/chatbot/messages" // API 엔드포인트
    private let urlSession = URLSession.shared
    // 항상 최신의 accessToken을 가져오도록 computed property로 변경
      private var authToken: String {
          KeychainWrapper.standard.string(forKey: "accessToken") ?? "DefaultAccessToken"
      }
    @AppStorage("username") public var username: String = KeychainWrapper.standard.string(forKey: "username") ?? ""
    @Published public var messages: [WooriMessageData] = []
    @State var isLoading = false
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
        isLoading = true // Start loading
        let task = urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                           self.isLoading = false // Stop loading
                       }
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
    public func sendUserMessage(message: String, typingMessage: String? = nil, isButtonClicked: Bool = false, latitude: Double, longitude: Double, completion: @escaping (Result<WooriMessageDetail, Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTypingMessage = typingMessage?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalMessage = trimmedMessage + (trimmedTypingMessage.map { " \($0)" } ?? "")
        let previousMessage = messages.count >= 3 ? messages[messages.count - 3].content : "No previous message"
        
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
    private let tokenManager = TokenManager.shared // 싱글톤 인스턴스 접근
    @StateObject private var locationManager = LocationManager()
    @State private var isFetchingLocation = false // 위치 정보 가져오는 중 여부
    @State private var navigateToTranslateView = false
    @State private var safariViewURL: URL? // Safari URL을 열기 위한 상태 변수
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appChatState: AppChatState
    @StateObject private var WviewModel = WooriChatAPI()
    @AppStorage("language") private var language = LanguageManager.shared.selectedLanguage
    @State private var typingMessageCurrent: String = ""

    @State private var userLatitude: Double = 0.0
    @State private var userLongitude: Double = 0.0
    @FocusState private var fieldIsFocused: Bool
    @Binding var typingMessage: String
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var isMessagesFetched = false // 메시지 로드 여부 확인 변수
    @State private var isLoading = false // 로딩 상태 추가

    var username: String = KeychainWrapper.standard.string(forKey: "username") ?? ""
    // 네이버 지도 URL 열기 함수를 수정
    private func openMapURL(_ url: URL) {
        if url.scheme == "nmap" {
            // 네이버 지도 앱 URL을 여는 경우
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // SafariView를 통해 웹 URL을 열도록 구성
            safariViewURL = url
        }
    }
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
                                                               onQuickReplyTap: handleQuickReplyTap,
                                                               isLoading: $isLoading
                                                           
                                                           )
                                .id(message.id)
                            }
                        }
                    }
                    .onAppear {
                        isLoading = true // 로딩 시작
                        // 첫 번째 갱신을 즉시 수행
                        tokenManager.checkAndRefreshTokenIfNeeded { isSuccess in
                            if isSuccess {
                                print("✅ Token refresh succeeded.")
                                // 필요한 추가 작업이 있으면 여기서 수행하세요
                            } else {
                                print("❌ Token refresh failed.")
                                // 실패 시 처리할 작업을 여기에 추가할 수 있습니다.
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                   isLoading = false
                               }
                        if !isMessagesFetched { // 메시지가 로드되지 않았다면 fetchWMessages 호출
                        WviewModel.fetchWMessages { result in
                            isLoading = false // 로딩 완료
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
                    .onChange(of: locationManager.userLatitude) { newLatitude in
                         userLatitude = newLatitude
                         print("Latitude updated in StartChatView: \(newLatitude)")
                     }
                     .onChange(of: locationManager.userLongitude) { newLongitude in
                         userLongitude = newLongitude
                         print("Longitude updated in StartChatView: \(newLongitude)")
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
                                isLoading = true // 로딩 시작
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
    
    private func handleQuickReplyTap(buttonLabel: String, actionValue: ActionValue?, memberInfo: MemberInfo?) {
        // 로딩 상태 시작
                isLoading = true

        VStack {
            if let actionValueText = actionValue?.text {
                VStack {
                    Text(buttonLabel)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text(actionValueText)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .padding(.horizontal, 16)
            } else {
                Text(buttonLabel)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .padding(.horizontal, 16)
            }
        }
        switch buttonLabel {
            case "Change Visa":
                sendMessage("Change Visa", isButtonClicked: true)
            case "Extend Visa":
                sendMessage("Extend Visa", isButtonClicked: true)
            case "Application Form":
                navigateToTranslateView = true
            case "Fill Application":
                navigateToTranslateView = true
            case "Hikorea Website":
                if let urlString = actionValue?.url, let url = URL(string: urlString) {
                    safariViewURL = url
                }
       
        case "Office Location":
                locationManager.requestLocation()
                // 사용자가 위치 정보를 요청하는 경우 메시지를 전송하고 위치 정보를 업데이트
                sendMessage("Office Location", isButtonClicked: true)
                
                // 응답이 돌아온 후 위치 정보와 지도 URL을 설정
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // 1초 후 위치 정보 사용
                    isLoading = false // 로딩 상태 종료
                    let userLatitude = memberInfo?.latitude ?? 0.0
                    let userLongitude = memberInfo?.longitude ?? 0.0
                    let destinationLatitude = actionValue?.latitude ?? 37.5698552
                    let destinationLongitude = actionValue?.longitude ?? 126.9814644
                    let encodedStartName = actionValue?.address?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let encodedEndName = actionValue?.office?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

                    print("Office Location Latitude: \(userLatitude), Office Location Longitude: \(userLongitude)")

                  
                }

        case "Open Map":
            // `Office Location` 응답에서 "Open Map"을 선택한 경우
            locationManager.requestLocation()
            
            print("Open Map Latitude: \(userLatitude), Open Map Longitude: \(userLongitude)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isLoading = false // 로딩 상태 종료
                let userLatitude = locationManager.userLatitude
                let userLongitude = locationManager.userLongitude

                if let destinationLatitude = actionValue?.latitude,
                   let destinationLongitude = actionValue?.longitude,
                   let address = actionValue?.address,
                   let address_eng = actionValue?.address_eng,
                   let officeName = actionValue?.office_eng {
                    
                    let encodedStartName = address_eng.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let encodedEndName = officeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    
                    let webMapURL = URL(string: "https://map.naver.com/v5/directions/-/141.39/\(destinationLatitude),\(destinationLongitude)?c=\(userLatitude),\(userLongitude),15,0,0,0,dh&dname=\(encodedEndName)&sname=\(encodedStartName)")!
                    let appMapURL = URL(string: "nmap://route/public?slat=\(userLatitude)&slng=\(userLongitude)&sname=\(encodedStartName)&dlat=\(destinationLatitude)&dlng=\(destinationLongitude)&dname=\(encodedEndName)&Woorinara=project.livinglab.zypher")!
                    // 수정된 부분
                    if appMapURL.scheme == "nmap" {
                        openMapURL(appMapURL)
                    } else {
                        safariViewURL = webMapURL // 웹 URL을 열 때는 SafariView를 사용
                    }
                } else {
                    alertMessage = "출발지와 도착지 정보가 없습니다."
                    isShowingAlert = true
                }
            }

        default:
            break
        }
    }

    
    // 메시지 전송 함수
    private func sendMessage(_ message: String, isButtonClicked: Bool = false) {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        isLoading = true // 로딩 상태 시작
        
        let messageRecord = WooriMessageData(content: trimmedMessage, sender: WviewModel.username, createdAt: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short), quickReplyButtons: nil)
        WviewModel.messages.append(messageRecord)
        
        WviewModel.sendUserMessage(message: trimmedMessage, typingMessage: typingMessage, isButtonClicked: isButtonClicked, latitude: userLatitude, longitude: userLongitude) { result in
            DispatchQueue.main.async {
                           isLoading = false //
            switch result {
            case .success:
                print("Message sent and response received.")
            case .failure(let error):
                alertMessage = "메시지 전송 실패: \(error.localizedDescription)"
                isShowingAlert = true
            }
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
    @StateObject var locationManager: LocationManager = .init()
    
    @State private var userLatitude: Double = 0.0
    @State private var userLongitude: Double = 0.0
    var message: WooriMessageData
    @State private var safariViewURL: URL? // Safari URL을 열기 위한 상태 변수
    @Binding var typingMessageCurrent: String
    var currentUser: String 
    var onQuickReplyTap: (String, ActionValue?, MemberInfo?) -> Void
    @Binding var isLoading: Bool // 상위 뷰에서 전달받은 로딩 상태

    @State private var alertMessage = ""
    @FocusState private var isActionTextFocused: Bool
    @FocusState private var isContentOrLabelFocused: Bool
    @State private var shouldFocusOnActionText: Bool = false
    @State private var openMapFocused: Bool = false // "Open Map" 버튼 포커스 상태
    @State private var focusedButtonLabel: String? // 현재 포커스된 버튼의 레이블
    @State private var lastMessageId: UUID? // Track the latest message ID
  

      var body: some View {
          ScrollViewReader { proxy in
              VStack {
                  HStack {
                      if message.sender == currentUser {
                          Spacer()
                          Text(message.content)
                              .padding()
                              .background(Color.gray)
                              .foregroundColor(.white)
                              .cornerRadius(14)
                      } else {
                       
                          // Display logo and message for bot's response
                          Image("chatLogo")
                              .resizable()
                              .scaledToFit()
                              .frame(width: 34, height: 34)
                          Text(message.content)
                              .padding()
                              .foregroundColor(.black)
                              .background(Color.blue.opacity(0.1))
                              .cornerRadius(14)
                          // Show message content or loading indicator
                          if isLoading == true && message.content.isEmpty{ // isLoading이 true일 때만 로딩 인디케이터 표시
                                                     HStack(alignment: .center, spacing: 1) {
                                                         Image("chatLoading")
                                                             .resizable()
                                                             .scaledToFit()
                                                             .frame(width: 100, height: 34)
                                                     }
                          } else if isLoading == false
                          {
                              
                                 // Display logo and message for bot's response
                                 Image("chatLogo")
                                     .resizable()
                                     .scaledToFit()
                                     .frame(width: 34, height: 34)
                                 Text(message.content)
                                     .padding()
                                     .foregroundColor(.black)
                                     .background(Color.blue.opacity(0.1))
                                     .cornerRadius(14)
                          }
                          Spacer()
                      }
                  }
                  .padding(.horizontal)
                  .id(message.id) // Assign a unique ID to each message


                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 10) {
                        if let quickReplyButtons = message.quickReplyButtons {
                            ForEach(quickReplyButtons, id: \.label) { button in
                                Button(action: {
                                    onQuickReplyTap(button.label, button.actionValue, MemberInfo.init(latitude: 0.0, longitude: 0.0))
                                    lastMessageId = message.id // Update lastMessageId to focus on the latest message
                                    if button.actionType == "map" {
                                        openMapFocused = true
                                    }
                                }) {
                                    VStack {
                                        if let actionText = button.actionValue?.text {
                                            VStack {
                                                Text(button.label)
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.blue)
                                                Text(actionText)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.gray)
                                                    .padding(.leading, 2)
                                            }
                                            .padding(.vertical, 1)
                                            .padding(.horizontal, 12)
                                            .background(Color.white)
                                            .cornerRadius(16)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.blue, lineWidth: 2)
                                            )
                                            .padding(.horizontal, 8)
                                        } else {
                                            Text(button.label)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.blue)
                                                .padding(.vertical, 1)
                                                .padding(.top, 3)
                                                .padding(.horizontal, 12)
                                                .background(Color.white)
                                                .cornerRadius(16)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.blue, lineWidth: 2)
                                                )
                                                .padding(.horizontal, 8)
                                                .focused($isActionTextFocused, equals: openMapFocused && button.label == "Open Map")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .onAppear {
                        if openMapFocused {
                            isActionTextFocused = true
                        } else {
                            isContentOrLabelFocused = true
                        }
                    }
                }
       
            
            }
        }
    }
}

// Example of a custom activity indicator view
struct iActivityIndicator: View {
    var style: Style

    var body: some View {
        HStack {
            ForEach(0..<style.count, id: \.self) { index in
                Circle()
                    .scaleEffect(style.scaleRange.contains(CGFloat(index) / CGFloat(style.count - 1)) ? style.scaleRange.upperBound : style.scaleRange.lowerBound)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1)
                    )
                    .frame(width: 10, height: 10)
            }
        }
    }
    
    struct Style {
        var count: Int
        var scaleRange: ClosedRange<CGFloat>
        
        static let rowOfShapes = Style(count: 3, scaleRange: 0.1...1)
    }
}

// 외부 Safari 브라우저 뷰를 지원하는 구조체는 http 및 https URLs만 열도록 제한됩니다.
// nmap:// 같은 앱 URL은 직접 열도록 처리합니다.
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
