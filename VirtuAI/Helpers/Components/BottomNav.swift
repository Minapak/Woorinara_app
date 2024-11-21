//
//  BottomNav.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 4.06.2023.
//

import Foundation
import SwiftUI

enum ScreensEnum: String, CaseIterable {
    case chat
    case translation
    case community
    case myPage
    case setting
}

enum TabType: Int, CaseIterable {
    case chat = 0
    case translation
    case community
    case myPage
    
    var tabItem: TabItemData {
        switch self {
        case .chat:
            return TabItemData(
                id: 0,
                image: "message",
                selectedImage: "message.fill",
                title: "Chat",
                isSystemImage: true  // SF Symbol 사용 여부를 나타내는 프로퍼티 추가
            )
        case .translation:
            return TabItemData(
                id: 1,
                image: "globe",
                selectedImage: "globe.fill",
                title: "Translation",
                isSystemImage: true
            )
        case .community:
            return TabItemData(
                id: 2,
                image: "person.3",
                selectedImage: "person.3.fill",
                title: "Community",
                isSystemImage: true
            )
        case .myPage:
            return TabItemData(
                id: 3,
                image: "person.circle",
                selectedImage: "person.circle.fill",
                title: "My page",
                isSystemImage: true
            )
        }
    }
}

struct CustomTabView: View {
    let tabs: [TabItemData]
    @Binding var selectedIndex: Int
    @EnvironmentObject var locationManager: LocationManager
    
    private var isLocationPermissionGranted: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse ||
        locationManager.authorizationStatus == .authorizedAlways
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                ForEach(tabs) { tab in
                    Button(action: {
                        if !isLocationPermissionGranted && tab.id != 0 {
                            return
                        }
                        selectedIndex = tab.id
                    }) {
                        VStack(spacing: 2) { // 간격을 4에서 2로 줄임
                            if tab.isSystemImage {
                                Image(systemName: selectedIndex == tab.id ? tab.selectedImage : tab.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24) // 아이콘 크기를 24에서 20으로 줄임
                            } else {
                                Image(selectedIndex == tab.id ? tab.selectedImage : tab.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24) // 아이콘 크기를 24에서 20으로 줄임
                            }
                            Text(tab.title)
                                .font(.system(size: 12)) // 글자 크기를 12에서 10으로 줄임
                        }
                        .foregroundColor(selectedIndex == tab.id ? Color.blue : Color.gray)
                        .opacity(!isLocationPermissionGranted && tab.id != 0 ? 0.5 : 1.0)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: 35) // 탭바 높이 고정
            .padding(.top, 3) // 상단 패딩 축소
            .padding(.bottom, 3) // 하단 Safe Area 고려
            .background(Color.white)
        }
    }
    
    // Safe Area 높이를 가져오는 함수
    private func getSafeAreaBottom() -> CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
        
        return keyWindow?.safeAreaInsets.bottom ?? 0
    }
}


struct TabBottomView: View {
    let tabbarItems: [TabItemData]
    @Binding var selectedIndex: Int
    
    var body: some View {
        HStack {
           // Spacer()
            
            ForEach(tabbarItems) { item in
                Button {
                    self.selectedIndex = item.id
                } label: {
                    let isSelected = selectedIndex == item.id
                    TabItemView(data: item, isSelected: isSelected)
                }
             //   Spacer()
            }
        }
//        .padding(.top, 7)
    }
}
// TabItemView 업데이트
struct TabItemView: View {
    let data: TabItemData
    let isSelected: Bool
    
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    
    var body: some View {
        VStack(spacing: 3) {
            if data.isSystemImage {
                // SF Symbol 이미지
                Image(systemName: isSelected ? data.selectedImage : data.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? Color.blue : Color.gray)
            } else {
                // 일반 이미지
                Image(isSelected ? data.selectedImage : data.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? Color.blue : Color.gray)
            }
            
            Text(data.title.localize(language))
                .font(.system(size: 12))
                .foregroundColor(isSelected ? Color.blue : Color.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TabItemData: Identifiable {
    let id: Int
    let image: String
    let selectedImage: String
    let title: String
    let isSystemImage: Bool  // SF Symbol 사용 여부를 나타내는 프로퍼티 추가
}

struct View_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
