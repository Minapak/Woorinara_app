//
//  StartChatView.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 3.06.2023.
//

import SwiftUI

struct StartChatView: View {
    
    @EnvironmentObject var appState: AppState
    
    
    @StateObject private var viewModel = StartChatViewModel()
    
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    
    @StateObject private var WviewModel = WooriChatAPI() // Using WooriChatAPI directly for simplicity
    @State private var isPresented = false
    @State private var showSuccessToast = false
    @State private var showErrorToast = false
    @State private var typingMessage: String = ""
    
    @State private var typingHint = ""
    @State private var currentIndex = 0
    @State private var currentIndexOfExample = 0
    @State private var isAnimating = false
    
    @Binding var typingMessageCurrent: String  // @State에서 @Binding으로 변경

    
    let examples: [ExamplesMainModel] = [
        ExamplesMainModel(image: "ExplainMain",
                          name: "explain",
                          example: [
                            "explain_example_1",
                            "explain_example_2",
                            "explain_example_3",
                            "explain_example_4",
                            "explain_example_5"
                          ]),

    ]
    
    
    
    @FocusState private var fieldIsFocused: Bool

    
    @FocusState private var focusedField: Field?
    @State private var navigateToChatViewForScan = false
    @State private var navigateToChatViewForSummarize = false
    @State private var firstMessageContent: String? // 첫 번째 메시지 내용을 저장할 상태 변수
    
    private enum Field: Int, CaseIterable {
        case message
    }
    var body: some View {
   
    
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                ZStack {
                    AppBar(title: "", isMainPage: true).padding(.horizontal,20)
                }
            
                ScrollView(.vertical, showsIndicators: false) {
  
                        
                        VStack(spacing: 10) {
//                            ForEach(WviewModel.messages, id: \.createdAt) { message in
//                                 MessageStartView(message: message, typingMessageCurrent: $typingMessageCurrent)  // 바인딩 전달
//                             }

                            if let firstMessage = WviewModel.messages.first {
                                MessageStartView(message: firstMessage,typingMessageCurrent: $typingMessageCurrent)
                                                 }
                        }.onAppear {
                            WviewModel.fetchWMessages { result in
                                switch result {
                                                          case .success(let messages):
                                                              print("Messages loaded successfully: \(messages.count) messages.")
                                                          case .failure(let error):
                                                              print("Error loading messages: \(error)")
                                                          }
                             
                            }
//                            self.typingMessageCurrent =  UserDefaults.standard.string(forKey: "ChatbotLabel") ?? "Ask anything to Woori!"
                        }
                        .padding(.vertical, 0)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 2)
                            ).padding(3)
                        
                    
               

                    
                }.padding(.horizontal,3)
                
                Spacer()
                
                VStack(spacing: 0)
                {
                    
                    HStack(alignment: .bottom,spacing: 15) {
                        
                        ZStack(alignment: .trailing)
                        {
                         
                            TextField("Ask anything to Woori!", text: $typingMessageCurrent,axis: .vertical)
                                .id(typingMessageCurrent)
                                .focused($fieldIsFocused)
                                .focused($focusedField, equals: .message)
                                .lineLimit(5)
                                .padding(.trailing,30)
                                .padding(15)
                                .background(fieldIsFocused ? Color.green_color.opacity(0.2) : Color.gray_color ).cornerRadius(16)
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            Color.green_color, lineWidth: fieldIsFocused ? 1.5 : 0
                                        )
                                })
                                .modifier(UrbanistFont(.semi_bold, size: 16))
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .onTapGesture {
                                    fieldIsFocused = true
                                }
                                .onAppear{
                                    // Disable this lines for Remove Typing Animation
                                    //  startTypingAnimation()
//                                                                self.typingMessageCurrent =  UserDefaults.standard.string(forKey: "ChatbotLabel") ?? "Ask anything to Woori!"
                                }
                            
                            
                            NavigationLink(destination: LazyView(ChatView(typingMessage : typingMessageCurrent, role: Constants.DEFAULT_AI)), label: {
                                
                                Image("Send")
                                    .resizable().scaledToFill()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                                
                            }) .padding(.trailing,15)
                            
                        }
                        .toolbar {
                            ToolbarItem(placement: .keyboard) {
                                HStack(alignment: .center, spacing: 0){
                                    
                                    Button("done".localize(language)) {
                                        focusedField = nil
                                    }.frame(maxWidth: .infinity,alignment : .trailing)
                                }
                                
                            }
                        }
                        
                        
                        
                        
                        
                        
                    }.padding(.bottom,20)
                        .onDisappear {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                        }
                }.background(Color.background).padding(.horizontal,20)
                
            }.frame(maxHeight:.infinity).padding(.bottom,5)
        }.onAppear{
            
            viewModel.getFreeMessageCount()
            
            if UserDefaults.isFirstTime && !UserDefaults.isProVersion
            {
                //isPresented.toggle()
                UserDefaults.isFirstTime = false
            }
            
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                appState.hideBottomNav = true
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { notification in
                appState.hideBottomNav = false
            }
            
        }
 
        
    }
    
    
    var exampleList: [String] {
        var result: [String] = []
        for exampleCategory in examples {
            for exampleItem in exampleCategory.example {
                result.append(exampleItem.localize(language))
            }
        }
        return result
    }
    
    
    func startTypingAnimation() {
        if !isAnimating {
            isAnimating = true
            if currentIndex < exampleList.count {
                let example = exampleList[currentIndex]
                typingHint = ""
                animateTypingRecursively(example: example, currentIndex: 0)
            } else {
                resetAnimation()
            }
        }
    }
    
    func resetAnimation() {
        currentIndex = 0
        typingHint = ""
        isAnimating = false
        startTypingAnimation()
    }
    
    
    func animateTypingRecursively(example: String, currentIndex: Int) {
        guard currentIndex < example.count else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isAnimating = false
                self.currentIndex += 1
                self.startTypingAnimation()
            }
            return
        }
        
        let index = example.index(example.startIndex, offsetBy: currentIndex)
        typingHint += String(example[index])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.animateTypingRecursively(example: example, currentIndex: currentIndex + 1)
        }
    }
}

struct MessageStartView: View {
    var message: WooriMessageData
    @Binding var typingMessageCurrent: String  // @State에서 @Binding으로 변경
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 10) {
                Image("chatLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)

                Text(message.content)
                    .padding()
                    .foregroundColor(.black)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            }

            ScrollView(.horizontal, showsIndicators: false) {  // 수평 스크롤 뷰 추가
                HStack(spacing: 10) {
                   
                        //typingMessageCurrent = button.label
                        ForEach(message.quickReplyButtons ?? [], id: \.label) { button in
                            Button(
                                action: {
                                    typingMessageCurrent = button.actionValue.value ?? "";                                print("Actiontextttt: \(button.actionValue.text ?? "No text available")")
                                print("ActionValueeee: \(button.actionValue.value ?? "No value available")")
                            }
                            )
                            {
                                Text(button.label)
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.vertical, 10)  // 세로 패딩
                                    .padding(.horizontal, 20)  // 가로 패딩
                                    .foregroundColor(.blue)
                                    .background(Color.white)
                                    .cornerRadius(10)
                             
                            }
                            
                        }
                    
                    
                }
            }
        }
    }
}

struct StartChatView_Previews: PreviewProvider {
    @State static var typingMessageCurrent: String = ""  // 미리보기용 상태 직접 생성

    static var previews: some View {
        StartChatView(typingMessageCurrent: $typingMessageCurrent)
            .environmentObject(AppState())
    }
}
