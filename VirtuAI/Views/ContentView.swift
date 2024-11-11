import SwiftUI
import CoreLocationUI
import CoreLocation

struct ContentView: View {
    @State var selectedIndex = 0
    @ObservedObject var viewModel = ContentViewModel()
    @EnvironmentObject var upgradeViewModel: UpgradeViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appChatState: AppChatState
    @EnvironmentObject var locationManager: LocationManager // LocationManager injected as an environment object
    @State static var typingMessageCurrent: String = ""
    
    @State private var showLocationAlert = false // State variable to control alert display

    var body: some View {
        if appChatState.isUserLoggedIn {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    TabView(selection: $selectedIndex) {
                        StartChatView(
                            appState: _appState,
                            appChatState: _appChatState,
                            typingMessage: ContentView.$typingMessageCurrent, isLoading: true
                        ).tag(0)
                        TranslationView().tag(1)
                        ContentWebView().tag(2)
                        TemporaryLinkView().tag(3)
                        SettingsView().tag(4)
                    }
                    
                    if !appState.hideBottomNav {
                        CustomTabView(tabs: TabType.allCases.map({ $0.tabItem }), selectedIndex: $selectedIndex)
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
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
