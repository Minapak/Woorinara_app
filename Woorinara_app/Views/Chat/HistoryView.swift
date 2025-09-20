//
//  HistoryView.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 4.06.2023.
//

import SwiftUI

struct HistoryView: View {
    @StateObject var viewModel = HistoryViewModel()
    @State var showSearch: Bool = false
    @State var showingDeleteSheet: Bool = false
    @State var searchText: String = ""
    @Environment(\.colorScheme) var colorScheme

    var filteredConversations: [ConverstionsModel] {
        if searchText.isEmpty {
            return viewModel.conversations
        } else {
            return viewModel.conversations.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                if showSearch {
                    SearchView(showSearch: $showSearch,searchText : $searchText).padding(.horizontal,20)
                } else {
                    AppBar(title: "history", isHistoryAppBar: true, onSearch: {
                        showSearch.toggle()
                    }, onDelete: {
                        showingDeleteSheet.toggle()
                    }).padding(.horizontal, 20)
                }
                
                if $viewModel.conversations.isEmpty {
                    VStack(spacing: 20) {
                        Image(colorScheme == .light ? "EmptyList" : "EmptyListDark")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 180, height: 180)
                          
                        Text("empty".localize(language))
                            .modifier(UrbanistFont(.bold, size: 25))
                            .foregroundColor(Color.green_color)
                        
                        Text("no_history".localize(language))
                            .modifier(UrbanistFont(.medium, size: 16))
                            .foregroundColor(Color.text_color)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredConversations) { conversation in
                                HistoryItem(conversation: $viewModel.conversations[getIndex(item: conversation)]) { id in
                                    viewModel.deleteHistoryItem(conversationId: id)
                                }.padding(.horizontal, 20)
                            }
                        }.padding(.vertical, 5)
                    }.frame(maxHeight: .infinity)
                }
            }.frame(maxHeight: .infinity)
        }.onAppear {
            viewModel.getConversations()
        }
        .sheet(isPresented: $showingDeleteSheet) {
            VStack {
                Rectangle()
                    .fill(Color.card_border)
                    .frame(width: 60, height: 4)
                    .cornerRadius(10, corners: .allCorners)
                    .padding(10)
                
                Text("clear_all_history".localize(language))
                    .modifier(UrbanistFont(.bold, size: 22))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.text_color)
                    .padding(.top, 4)
                
                Rectangle()
                    .fill(Color.card_border)
                    .frame(height: 2)
                    .cornerRadius(10, corners: .allCorners)
                    .padding(10)
                
                Text("are_you_sure_delete_all_history".localize(language))
                    .modifier(UrbanistFont(.bold, size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.text_color)
                    .padding(.top, 4)
                
                Spacer().frame(height: 35)
                
                HStack(spacing: 15) {
                    Button {
                        showingDeleteSheet.toggle()
                    } label: {
                        Text("cancel".localize(language))
                            .modifier(UrbanistFont(.bold, size: 16))
                            .foregroundColor(.green_color)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.green_color.opacity(0.2))
                            .cornerRadius(99)
                    }.buttonStyle(BounceButtonStyle())
                    
                    Button {
                        showingDeleteSheet.toggle()
                        viewModel.deleteAllConversations()
                    } label: {
                        Text("yes_clear_all".localize(language))
                            .modifier(UrbanistFont(.bold, size: 16))
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.green_color)
                            .cornerRadius(99)
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 6)
                    }.buttonStyle(BounceButtonStyle())
                }
            }
            .padding(15)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .presentationDetents([.height(280)])
            .presentationBackground {
                VStack {
                    Spacer()
                }
                .padding(15)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.light_gray)
                .cornerRadius(50)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.card_border, lineWidth: 2)
                )
                .padding(3)
            }
        }
    }
    
    func getIndex(item: ConverstionsModel) -> Int {
        return viewModel.conversations.firstIndex { item.id == $0.id } ?? 0
    }
}
struct SearchView : View {
    @Binding var showSearch : Bool
    @FocusState private var fieldIsFocused: Bool
    @Binding var searchText: String
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    var body: some View{
        HStack(spacing: 15)
        {
            Button {
                showSearch.toggle()
            } label: {
                Image("ArrowLeft")
                    .resizable().scaledToFill()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.text_color)
            }
            
            
            TextField("search_conversation".localize(language), text: $searchText,axis: .vertical)  .frame(maxWidth: .infinity)
                .focused($fieldIsFocused)
                .lineLimit(5)
                .padding(15)
                .background(fieldIsFocused ? Color.green_color.opacity(0.2) : Color.gray_color ).cornerRadius(16)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color.green_color, lineWidth: fieldIsFocused ? 1.5 : 0
                        )
                })
                .modifier(UrbanistFont(.medium, size: 16))
                .disableAutocorrection(true)
                .autocapitalization(.none)
            
                .onTapGesture {
                    fieldIsFocused = true
                }.onDisappear {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                }
            
            
            
        }.padding(.vertical,2.5)
        
    }
}

struct HistoryItem: View {
    @Binding var conversation: ConverstionsModel
    var onDelete: (String) -> Void = { _ in }

    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage

    var body: some View {
        NavigationLink(destination: TemporaryLinkView()
//                        LazyView(
//                            ChatView(
//                                role: Constants.DEFAULT_AI, conversationId: conversation.conversationId, historyGPTModel: conversation.gptModel)
//                        )
        ) {
            itemContent
        }
        .buttonStyle(BounceButtonStyle())
    }

    // Separate the content of the item into a computed property to simplify the body.
    var itemContent: some View {
        ZStack {
            Color.red_color
                .cornerRadius(20)
                .padding(.vertical, 4)

            swipeDeleteButton

            conversationDetails
                .padding(12)
                .background(Color.light_gray)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.card_border, lineWidth: 2))
                .padding(.vertical, 4)
                .offset(x: conversation.offset)
                .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:)))
        }
    }

    // Separate the swipe delete button logic
    var swipeDeleteButton: some View {
        HStack {
            Spacer()

            Button {
                withAnimation(.easeIn) {
                    onDelete(conversation.conversationId)
                }
            } label: {
                Image("DeleteFilled")
                    .frame(width: 90, height: 50)
                    .foregroundColor(.white)
            }
        }
    }

    // Separate the conversation details logic
    var conversationDetails: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(conversationTitle)
                    .modifier(UrbanistFont(.bold, size: 18))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .foregroundColor(Color.text_color)

                Spacer().frame(height: 10)

                Text(conversation.createdAt)
                    .modifier(UrbanistFont(.medium, size: 12))
                    .foregroundColor(Color.inactive_input)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image("Right")
                .resizable()
                .scaledToFill()
                .frame(width: 20, height: 20)
                .foregroundColor(.text_color)
        }
    }

    // Simplify title logic into a separate variable
    var conversationTitle: String {
        if conversation.title.starts(with: Constants.START_WEB_LINK) {
            let webPageTitle = conversation.title.split(separator: "||").dropFirst().first ?? ""
            return "web_page".localize(language) + " (\(webPageTitle))"
        } else {
            return conversation.title
        }
    }

    // Gesture handling logic
    func onChanged(value: DragGesture.Value) {
        if value.translation.width < 0 {
            conversation.offset = conversation.isSwiped ? value.translation.width - 90 : value.translation.width
        }
    }

    func onEnd(value: DragGesture.Value) {
        withAnimation(.easeOut) {
            if value.translation.width < 0 {
                if -value.translation.width > UIScreen.main.bounds.width / 2 {
                    conversation.offset = -1000
                    onDelete(conversation.conversationId)
                } else if -conversation.offset > 50 {
                    conversation.isSwiped = true
                    conversation.offset = -90
                } else {
                    conversation.isSwiped = false
                    conversation.offset = 0
                }
            } else {
                conversation.isSwiped = false
                conversation.offset = 0
            }
        }
    }
}

