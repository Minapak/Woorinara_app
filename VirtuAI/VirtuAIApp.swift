//
//  VirtuAIApp.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 3.06.2023.
//
import GoogleMobileAds
import SwiftUI
import RevenueCat
import UIKit
import FirebaseCore
import GoogleSignIn

@main
struct VirtuAIApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var upgradeViewModel = UpgradeViewModel()
    @StateObject var appState = AppState()

    @AppStorage(Constants.Preferences.DARK_MODE)
    private var isDarkTheme = UserDefaults.isDarkTheme
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SplashView()
                .preferredColorScheme(isDarkTheme ? .dark : .light)
                .environmentObject(upgradeViewModel)
                .environmentObject(appState)

        }  .onChange(of: scenePhase) { (newScenePhase) in
            if case .active = newScenePhase {
                initMobileAds()
            }
        }
    }

    
      func initMobileAds() {
          GADMobileAds.sharedInstance().start(completionHandler: nil)
          // comment this if you want SDK Crash Reporting:
          GADMobileAds.sharedInstance().disableSDKCrashReporting()
      }
    
    init() {        
//        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Constants.REVENUE_CAT_API_KEY)
        
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate {
     
        var ConversionData: [AnyHashable: Any]? = nil
         var window: UIWindow?
         var deferred_deep_link_processed_flag:Bool = false

         func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
             FirebaseApp.configure()
             return true
         }

         func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
             return true
         }
                 
         func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
             return GIDSignIn.sharedInstance.handle(url)
         }
         
         func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
         }
         
     }


    
    
}
