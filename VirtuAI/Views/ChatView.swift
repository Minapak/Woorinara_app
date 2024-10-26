//
//  ChatView.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 4.06.2023.
//

import SwiftUI
import Combine
import PopupView
import Speech
import PhotosUI
import Vision
import SwiftSoup

struct ChatView: View {
    // `presentationMode`를 사용해 이전 화면으로 돌아가는 동작을 제어하는 변수입니다.
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // `ChatViewModel`의 인스턴스를 생성하여 뷰와 연동합니다.
    @StateObject var viewModel = ChatViewModel()
    // 사용자가 입력한 메시지를 저장하는 변수입니다.
    @State var typingMessage: String = ""
    // 채팅 화면의 제목을 나타내는 변수입니다.
    var name: String = "app_name"
    // 역할을 설정하는 변수로, 사용자의 역할을 정의합니다.
    var role: String
    // 현재 대화 ID를 저장하는 변수입니다.
    @State var conversationId: String = ""
    // GPT 모델을 저장하는 변수입니다.
    @State var historyGPTModel: String = ""
    // 예시 메시지를 저장하는 배열입니다.
    var examples: [String]?
    // 입력 필드가 포커스 상태인지 확인하는 변수입니다.
    @FocusState private var fieldIsFocused: Bool
    // 하단 여백을 제어하는 변수입니다.
    @State var paddingBottom: CGFloat = 0.0
    // 유효하지 않은 URL을 입력했을 때 경고 메시지를 보여주는 상태 변수입니다.
    @State private var showInvalidURLErrorToast = false

    // 팝업 관련 상태 변수입니다.
    @State private var isPresented = false
    @State private var showTtsWarn = false
    
    // `AppStorage`를 사용하여 저장된 언어 설정을 불러옵니다.
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    
    // 업그레이드 관련 상태를 제어하는 환경 객체입니다.
    @EnvironmentObject var upgradeViewModel: UpgradeViewModel
    @State var showSuccessToast = false
    @State var showErrorToast = false

    // 미디어 관련 상태 변수들입니다.
    @State var showingMediaSheet = false
    @State private var showingScanningView = false
    @State var showingChooseScanTypeSheet = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingImageCropper = false
    @State var showingLinkSummarizer = false
    @State private var showingSelectGPT = false

    // URL 입력 및 텍스트 처리 관련 변수입니다.
    @State var urlEntered: String = ""
    @State private var linkText: String = ""
    // 필드를 구분하는 enum 타입입니다.
    @FocusState private var focusedField: Field?
    private enum Field: Int, CaseIterable {
        case message
    }
    
    // 앱의 상태를 제어하는 환경 객체입니다.
    @EnvironmentObject var appState: AppState
    
    // 화면의 body 부분입니다. SwiftUI의 메인 뷰 구조입니다.
    var body: some View {
        NavigationStack {
            ZStack {
                // 전체 배경색 지정
                Color.background.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 0) {
                    // 상단 바 영역
                    ZStack {
                        AppBar(imageName: "ArrowLeft", title: name, isChatPage: true, isDefault: false, onBack: {
                            // 뒤로가기 버튼 클릭 시 메시지 생성을 중단하고 이전 화면으로 이동
                            viewModel.stopGenerate()
                            self.presentationMode.wrappedValue.dismiss()
                        }).padding(.horizontal, 20)
                    }
                    
                    ZStack {
                        // 메시지가 없으면 예시 또는 기능 설명을 표시
                        if viewModel.messages.isEmpty {
                            // 메시지 리스트를 표시
                            MessageList(isGenerating: $viewModel.isGeneratingWithoutAnimation, onRegenerate: regenerateAnswer, messages: viewModel.messages).padding(.bottom, paddingBottom)
                            
                        } else {
                            // 메시지 리스트를 표시
                            MessageList(isGenerating: $viewModel.isGeneratingWithoutAnimation, onRegenerate: regenerateAnswer, messages: viewModel.messages).padding(.bottom, paddingBottom)
                        }

                        // 메시지 생성 중일 때 '중지' 버튼 표시
                        VStack {
                            Spacer()
                            if viewModel.isGenerating {
                                StopButton(onClick: {
                                    viewModel.stopGenerate() // 메시지 생성을 중단하는 버튼
                                }).transition(.move(edge: .bottom))
                            }
                        }.frame(maxHeight: .infinity)
                    }.frame(maxHeight: .infinity)
                    
                    // 하단 메시지 입력 및 전송 버튼
                    VStack(spacing: 0) {
                        Divider().frame(height: 2)
                        Spacer().frame(height: 15)
                        HStack(alignment: .bottom, spacing: 15) {

                            // 사용자 입력 필드
                            TextField("ask_me_anything", text: $typingMessage, axis: .vertical)
                                .focused($fieldIsFocused) // 입력 필드 포커스 상태 설정
                                .lineLimit(5)
                                .padding(15)
                                .background(fieldIsFocused ? Color.green_color.opacity(0.2) : Color.gray_color)
                                .cornerRadius(16)
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.green_color, lineWidth: fieldIsFocused ? 1.5 : 0)
                                })
                                .modifier(UrbanistFont(.semi_bold, size: 16))
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .onTapGesture {
                                    fieldIsFocused = true
                                }
                            
                            // 전송 버튼
                            Button {
                                if typingMessage.isEmpty {
                                    sendMessage()
                                } else {
                                    sendMessage()
                                }
                            } label: {
                                Image(typingMessage.isEmpty ? "Send" : "Send")
                                    .resizable().scaledToFill()
                                    .frame(width: 25, height: 25)
                            }.frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .background(Color.blue).cornerRadius(99)
                        }.padding(.bottom, 20).padding(.horizontal, 20)
                            .onDisappear {
                                // 필드 포커스 해제
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                    }.background(Color.background)
                }.frame(maxHeight: .infinity)
            }.frame(maxHeight: .infinity)
                .onAppear {
                    // 화면이 나타날 때 데이터를 설정
                    viewModel.role = self.role
                    viewModel.conversationId = self.conversationId
                    viewModel.historyGPTModel = self.historyGPTModel
                    viewModel.getSelectedGPT()
                    viewModel.removeHistory()
                    viewModel.getMessagesHistory()
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())  // StackNavigation 스타일 적용
        .navigationBarHidden(true)  // 네비게이션 바 숨김
        .navigationBarBackButtonHidden(true)  // 뒤로 가기 버튼 숨김
    }
    
    // HTML 콘텐츠를 가져오는 함수, 비동기로 URL의 데이터를 가져와서 텍스트로 변환합니다.
    func fetchHTMLContent() async {
        guard let url = URL(string: urlEntered), UIApplication.shared.canOpenURL(url) else {
            showInvalidURLErrorToast = true
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let htmlString = String(data: data, encoding: .utf8) else {
                showInvalidURLErrorToast = true
                return
            }
            
            let document = try SwiftSoup.parse(htmlString)
            let text = try document.text()
            
            await MainActor.run {
                urlEntered  = ""
                sendMessage()
            }
        } catch {
            print("Failed to fetch or parse HTML content: \(error)")
            showInvalidURLErrorToast = true
        }
    }
    
    // 메시지를 전송하는 함수
    private func sendMessage() {
        if !viewModel.isGenerating {
            guard !typingMessage.isEmpty else { return }
            let tempMessage = typingMessage
            typingMessage = ""
            hideKeyboard()
            Task{
                await viewModel.getResponse(text: tempMessage)
            }
        }
    }
    
    // 답변을 다시 생성하는 함수
    private func regenerateAnswer() {
        if !viewModel.isGenerating {
            hideKeyboard()
            Task{
                await viewModel.regenerateAnswer()
            }
        }
    }
    
    // 키보드를 숨기는 함수
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // 모든 시트를 닫는 함수
    private func dismissAllSheets() {
        showingMediaSheet = false
        showingScanningView = false
        showingChooseScanTypeSheet = false
        showingImagePicker = false
        showingImageCropper = false
        showingLinkSummarizer = false
        showingSelectGPT = false
    }
    
    // StopButton: 메시지 생성을 중단하는 버튼 UI를 정의하는 뷰입니다.
    struct StopButton : View {
        var onClick : () -> Void = {}
        @AppStorage("language")
        private var language = LanguageManager.shared.selectedLanguage
        
        var body: some View {
            Button {
                onClick()  // 버튼 클릭 시 메시지 생성을 중단
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    VStack {}.frame(width: 25, height: 25).background(Color.green_color).cornerRadius(6)
                    Text("stop_generating".localize(language))  // 언어에 맞춘 텍스트 표시
                        .modifier(UrbanistFont(.bold, size: 16))
                        .foregroundColor(Color.inactive_input)
                }
                .padding(.horizontal, 15)
                .frame(height: 60)
                .background(Color.light_gray)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16).stroke(Color.card_border, lineWidth: 2)
                ).padding(10)
            }
            .buttonStyle(BounceButtonStyle())
        }
    }
    
    // Capabilities: 앱의 기능 설명을 보여주는 뷰입니다.
    struct Capabilities : View {
        @AppStorage("language")
        private var language = LanguageManager.shared.selectedLanguage
        
        var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 15) {
                    Spacer().frame(height: 30)
                    Image("AppVectorIcon").resizable().scaledToFill().frame(width: 100, height: 100).foregroundColor(.inactive_input)
                    
                    Text("capabilities".localize(language))  // 기능 설명 타이틀
                        .modifier(UrbanistFont(.bold, size: 20)).foregroundColor(Color.inactive_input)
                    
                    Text("capabilities_1".localize(language))  // 첫 번째 기능 설명
                        .modifier(UrbanistFont(.medium, size: 14)).foregroundColor(.inactive_input)
                        .padding(20).background(Color.light_gray).cornerRadius(14).padding(.horizontal, 20)
                    
                    Text("capabilities_2".localize(language))  // 두 번째 기능 설명
                        .modifier(UrbanistFont(.medium, size: 14)).foregroundColor(.inactive_input)
                        .padding(20).background(Color.light_gray).cornerRadius(14).padding(.horizontal, 20)
                    
                    Text("capabilities_3".localize(language))  // 세 번째 기능 설명
                        .modifier(UrbanistFont(.medium, size: 14)).foregroundColor(.inactive_input)
                        .padding(20).background(Color.light_gray).cornerRadius(14).padding(.horizontal, 20)
                    
                    Text("capabilities_desc".localize(language))  // 기능 설명 텍스트
                        .modifier(UrbanistFont(.medium, size: 14)).foregroundColor(Color.inactive_input)
                        .padding(.top, 5)
                }
            }.frame(maxHeight: .infinity, alignment: .top).onAppear {
                UIScrollView.appearance().keyboardDismissMode = .interactive
            }
        }
    }
    
    // Examples: 사용자에게 예시 메시지를 보여주는 뷰입니다.
    struct Examples : View {
        @Binding var typingMessage: String  // 입력 중인 메시지를 바인딩
        var examples: [String]  // 예시 메시지 목록
        @AppStorage("language")
        private var language = LanguageManager.shared.selectedLanguage
        
        var body: some View {
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: 15) {
                        Spacer().frame(height: 30)
                        
                        Text("type_something_like".localize(language))  // "이런 식으로 입력해보세요" 문구
                            .modifier(UrbanistFont(.bold, size: 20)).foregroundColor(Color.inactive_input)
                        
                        ForEach(examples, id: \.self) { example in
                            Button {
                                typingMessage = example.localize(language)  // 버튼 클릭 시 해당 예시를 입력 필드에 추가
                            } label: {
                                Text(example.localize(language))
                                    .modifier(UrbanistFont(.medium, size: 14))
                                    .foregroundColor(.inactive_input).padding(20)
                                    .frame(maxWidth: .infinity).multilineTextAlignment(.center)
                                    .background(Color.light_gray).cornerRadius(14).padding(.horizontal, 20)
                            }.buttonStyle(BounceButtonStyle())
                        }
                    }.frame(width: geometry.size.width).frame(minHeight: geometry.size.height)
                }.frame(maxHeight: .infinity, alignment: .center).onAppear {
                    UIScrollView.appearance().keyboardDismissMode = .interactive
                }
            }
        }
    }
    
    // MessageList: 메시지 리스트를 표시하는 뷰입니다.
    struct MessageList: View {
        @Namespace var bottomID
        @Binding var isGenerating: Bool  // 메시지 생성 여부
        let onRegenerate: () -> Void  // 답변 다시 생성 함수
        var messages: [MessageModel]  // 메시지 리스트
        
        var body: some View {
            ScrollViewReader { reader in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack {
                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                            LazyView(MessageCard(message: message, isLastMessage: index == (messages.count - 1), isGenerating: $isGenerating, onRegenerate: onRegenerate)).padding(.top, index == 0 ? 8 : 0)
                        }
                        Text("").id(bottomID)
                    }.padding(.horizontal, 16)
                }.frame(maxHeight: .infinity)
                    .onChange(of: messages.last?.content as? String) { _ in
                        DispatchQueue.main.async {
                            withAnimation {
                                reader.scrollTo(bottomID)  // 메시지 전송 시 자동 스크롤
                            }
                        }
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            reader.scrollTo(bottomID)  // 메시지 개수 변경 시 자동 스크롤
                        }
                    }
                    .onAppear {
                        withAnimation {
                            reader.scrollTo(bottomID)
                        }
                        UIScrollView.appearance().keyboardDismissMode = .interactive
                    }
            }.frame(maxHeight: .infinity, alignment: .top)
        }
    }
}
