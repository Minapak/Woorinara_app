import SwiftUI
import CoreLocationUI
import CoreLocation

// TabMapType 열거형을 외부에 정의하여 모든 뷰에서 접근 가능하게 설정
enum TabMapType: CaseIterable {
    case chat, translation, community, mypage

    var title: String {
        switch self {
        case .chat: return "Chat"
        case .translation: return "Translation"
        case .community: return "Community"
        case .mypage: return "My Page"
        }
    }
}

struct permissionMapView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appChatState: AppChatState
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedIndex: Int = 6  // Set to an invalid index so no tab is initially selected
    @State private var showPermissionAlert = false  // Control alert display for location permission
    @State private var navigateToContentView = false  // Navigate to ContentView when permission is granted

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    AppBar(title: "", isMainPage: true)

                    Spacer()

                    VStack(spacing: 30) {
                        Text("Your location is used while the app is in use. Would you like to allow this permission?")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding()

                        HStack(spacing: 20) {
                            // Yes button - requests location permission and closes the view
                            LocationButton(.currentLocation) {
                                locationManager.requestLocationPermissions()
                            }
                            .frame(width: 200, height: 44)
                            .foregroundColor(.white)
                            .cornerRadius(16)

                            // No button - closes the view
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

                    Spacer()
                }
                .padding(.horizontal, 16)

          
            }
            .navigationDestination(isPresented: $navigateToContentView) {
                ContentView()
                    .environmentObject(appState)
                    .environmentObject(appChatState)
                    .environmentObject(locationManager)
            }
            .navigationBarBackButtonHidden(false) // Hide the back button
            .onAppear {
                appState.hideBottomNav = false// Ensure bottom nav is visible on appear
            }
//            .onDisappear {
//                appState.hideBottomNav = false // Hide bottom nav when navigating away
//            }
            .alert(isPresented: $showPermissionAlert) {
                Alert(
                    title: Text("Location Permission Required"),
                    message: Text("Please grant location access to use this feature."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onChange(of: locationManager.authorizationStatus) { newStatus in
                // Navigate to ContentView when permission is granted
                if isPermissionGranted() {
                    navigateToContentView = true
                }
            }
        }
    }
    
    // Check if location permission is granted
    private func isPermissionGranted() -> Bool {
        return locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways
    }
}

// CustomTabView with isDisabled and onTabTapped callback


struct permissionMapView_Previews: PreviewProvider {
    static var previews: some View {
        permissionMapView()
            .environmentObject(AppState())
            .environmentObject(AppChatState())
            .environmentObject(LocationManager())
    }
}
