//
//  ContentView.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 3.06.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var selectedIndex = 0

    @ObservedObject var viewModel  = ContentViewModel()
    @EnvironmentObject var upgradeViewModel: UpgradeViewModel
    @EnvironmentObject var appState: AppState
    @State static var typingMessageCurrent: String = "" // Create a mutable state for preview

    var body: some View {
        NavigationStack {
        
            ZStack(alignment: .bottom)
            {
                TabView(selection: $selectedIndex)
                {
                    StartChatView(typingMessageCurrent: ContentView.$typingMessageCurrent).tag(0)
                    ImageViewer().tag(1)
                    ContentWebView().tag(2)
                    ContentVcomView().tag(3)
                    SettingsView().tag(4)
                }
               
                if !appState.hideBottomNav {
                    CustomTabView(tabs: TabType.allCases.map({ $0.tabItem }), selectedIndex: $selectedIndex )

                }
//                ZStack
//                {
//                    Rectangle()
//                        .foregroundColor(Color.black)
//                        .opacity(upgradeViewModel.isLoading ? 0.5: 0.0)
//                        .edgesIgnoringSafeArea(.all)
//                    
//                    ProgressView()
//                        .scaleEffect(2, anchor: .center)
//                        .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
//                    
//                }.opacity(upgradeViewModel.isLoading ? 1: 0.0).edgesIgnoringSafeArea(.all)
           
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
