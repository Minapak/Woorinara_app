//
//  ContentView.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 3.06.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var selectedIndex = 0
    @ObservedObject var viewModel = ContentViewModel()
    @EnvironmentObject var upgradeViewModel: UpgradeViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appChatState: AppChatState
    @State static var typingMessageCurrent: String = "" // Create a mutable state for preview


    var body: some View {
        NavigationStack {
        
            ZStack(alignment: .bottom)
            {
                TabView(selection: $selectedIndex)
                {
                    StartChatView(
                        appState: _appState,
                        appChatState: _appChatState,
                                           userLatitude: 37.7749,
                                           userLongitude: -122.4194,
                                           typingMessage: ContentView.$typingMessageCurrent
                                       )
                                       .tag(0)
                    TranslationView().tag(1)
                    ContentWebView().tag(2)
                    TemporaryLinkView().tag(3)
                    SettingsView().tag(4)
                }
               
                if !appState.hideBottomNav {
                    CustomTabView(tabs: TabType.allCases.map({ $0.tabItem }), selectedIndex: $selectedIndex )

                }

           
            }
        
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
   
    
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
