import SwiftUI
import CoreLocationUI
import CoreLocation

struct ContentView: View {
    @State var selectedIndex = 0
    @ObservedObject var viewModel = ContentViewModel()
    @EnvironmentObject var upgradeViewModel: UpgradeViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appChatState: AppChatState
    @EnvironmentObject var locationManager: LocationManager
    @State static var typingMessageCurrent: String = ""
    
    @State private var showLocationAlert = false
    @State private var isLocationPermissionGranted = false
    @AppStorage(Constants.isFirstLogin) private var isFirstLogin = true
    @AppStorage(Constants.hasCompletedARC) private var hasCompletedARC = false
    
    var body: some View {
        if appChatState.isUserLoggedIn {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    TabView(selection: $selectedIndex) {
                        if !isLocationPermissionGranted {
                            permissionMapView()
                                .environmentObject(appState)
                                .environmentObject(appChatState)
                                .environmentObject(locationManager)
                                .tag(0)
                        } else if isFirstLogin == true{
                            ARCInfoView()
                                .environmentObject(appState)
                                .environmentObject(appChatState)
                                .tag(0)
                        } else {
                            StartChatView(
                                selectedIndex: $selectedIndex, appState: _appState,
                                appChatState: _appChatState,
                                typingMessage: ContentView.$typingMessageCurrent
                            )
                            .tag(0)
                        }
                        
                        TranslationView().tag(1)
                        ContentWebView().tag(2)
                        MyPageView().tag(3)
                    }
                    
                    if !appState.hideBottomNav && !(isFirstLogin) {
                                          CustomTabView(tabs: TabType.allCases.map({ $0.tabItem }), selectedIndex: $selectedIndex)
                                      }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationViewStyle(StackNavigationViewStyle())
            .onChange(of: locationManager.authorizationStatus) { newStatus in
                withAnimation {
                    isLocationPermissionGranted = (newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways)
                }
            }
            .onAppear {
                isLocationPermissionGranted = (locationManager.authorizationStatus == .authorizedWhenInUse ||
                                            locationManager.authorizationStatus == .authorizedAlways)
                
                if !isLocationPermissionGranted {
                    selectedIndex = 0
                }
            }
        } else {
            LoginView()
        }
    }
}
// Custom Location Permission Request View
struct LocationPermissionRequestView: View {
    @Binding var showLocationAlert: Bool
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Location Permission Required")
                .font(.headline)
                .padding(.top)
            
            Text("This app requires location access to provide better services. Please allow location access.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            LocationButton(.currentLocation) {
                locationManager.requestLocationPermissions()
                showLocationAlert = false // Dismiss the alert after permission is requested
            }
            .symbolVariant(.fill)
            .labelStyle(.titleAndIcon)
            .frame(maxWidth: .infinity, minHeight: 44)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
            
            Button("Cancel") {
                showLocationAlert = false // Dismiss alert on cancel
            }
            .foregroundColor(.red)
            .padding(.bottom)
        }
        .padding()
        .frame(width: 300, height: 250)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
