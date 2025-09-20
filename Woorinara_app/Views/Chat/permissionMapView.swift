import SwiftUI
import Foundation
import CoreLocation
import Combine
import CoreLocationUI
import MapKit

struct permissionMapView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appChatState: AppChatState
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedIndex: Int = 0
    @State private var showPermissionAlert = false
    @State private var navigateToContentView = false
    @State private var showLocationOverlay = false
    @State private var navigateToARCInfo = false
    @AppStorage(Constants.isFirstLogin) private var isFirstLogin = true
    
    private var tabItems: [TabItemData] {
        TabType.allCases.map { $0.tabItem }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 배경색
            Color.background.ignoresSafeArea(.all)
            
            // 메인 컨텐츠
            VStack(spacing: 0) {
                // 앱바
                AppBar(title: "", isMainPage: true)
                    .padding(.horizontal)
                
                // 맵과 오버레이
                ZStack {
                    Map(coordinateRegion: $locationManager.region, showsUserLocation: true)
                    
                    if !showLocationOverlay {
                        Color.black.opacity(0.1)
                        permissionRequestView
                    }
                }
                
                Spacer(minLength: 0)
            }
            
            // 탭바
            if !appState.hideBottomNav {

            }
        }
        // ARCInfoView로 이동하는 NavigationLink
        .navigationDestination(isPresented: $navigateToARCInfo) {
            ARCInfoView()
                .environmentObject(appState)
                .environmentObject(appChatState)
        }
        // 일반 ContentView로 이동하는 NavigationLink
        .navigationDestination(isPresented: $navigateToContentView) {
            ContentView()
                .environmentObject(appState)
                .environmentObject(appChatState)
                .environmentObject(locationManager)
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showPermissionAlert) {
            Alert(
                title: Text("Location Permission Required"),
                message: Text("Please grant location access to use this feature."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: locationManager.authorizationStatus) { newStatus in
            if isPermissionGranted() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if isFirstLogin {
                        navigateToARCInfo = true
                    } else {
                        navigateToContentView = true
                    }
                }
            }
        }
        .onChange(of: selectedIndex) { newIndex in
            if !isPermissionGranted() {
                showPermissionAlert = true
                selectedIndex = 0  // 위치 권한이 없으면 첫 번째 탭으로 강제 이동
            }
        }
    }
    
    // 권한 요청 뷰
    private var permissionRequestView: some View {
        VStack(spacing: 30) {
            Text("Your location is used while the app is in use. Would you like to allow this permission?")
                .font(.system(size: 18))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding()
            
            HStack(spacing: 20) {
                LocationButton(.currentLocation) {
                    locationManager.requestLocationPermissions()
                    withAnimation {
                        showLocationOverlay = true
                    }
                }
                .frame(width: 200, height: 44)
                .foregroundColor(.white)
                .cornerRadius(16)
                
                Button(action: {
                    showPermissionAlert = true
                }) {
                    Text("No")
                        .foregroundColor(.primary)
                        .frame(width: 100, height: 44)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(16)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .padding()
    }
    
    private func isPermissionGranted() -> Bool {
        return locationManager.authorizationStatus == .authorizedWhenInUse ||
               locationManager.authorizationStatus == .authorizedAlways
    }
}
