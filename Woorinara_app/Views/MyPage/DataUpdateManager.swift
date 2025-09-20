//
//  DataUpdateManager.swift
//  VirtuAI
//
//  Created by 박은민 on 11/24/24.
//
import SwiftUI
import Combine

class DataUpdateManager: ObservableObject {
    // Published properties to track data updates
    @Published var dataUpdated = false
    @Published var arcDataUpdated = false
    @Published var passportDataUpdated = false
    @Published var myInfoDataUpdated = false
    
    // Singleton instance
    static let shared = DataUpdateManager()
    
    private init() {
        // Setup notification observers
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        // Observer for general data updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataUpdate),
            name: Notification.Name("DataUpdateCompleted"),
            object: nil
        )
        
        // Observer for specific data updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleARCUpdate),
            name: Notification.Name("ARCDataUpdated"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePassportUpdate),
            name: Notification.Name("PassportDataUpdated"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMyInfoUpdate),
            name: Notification.Name("MyInfoDataUpdated"),
            object: nil
        )
    }
    
    // Handlers for data updates
    @objc private func handleDataUpdate() {
        DispatchQueue.main.async {
            self.dataUpdated = true
            print("📱 Data update notification received")
        }
    }
    
    @objc private func handleARCUpdate() {
        DispatchQueue.main.async {
            self.arcDataUpdated = true
            print("📱 ARC data update notification received")
        }
    }
    
    @objc private func handlePassportUpdate() {
        DispatchQueue.main.async {
            self.passportDataUpdated = true
            print("📱 Passport data update notification received")
        }
    }
    
    @objc private func handleMyInfoUpdate() {
        DispatchQueue.main.async {
            self.myInfoDataUpdated = true
            print("📱 MyInfo data update notification received")
        }
    }
    
    // Methods to trigger data updates
    func triggerDataUpdate() {
        NotificationCenter.default.post(name: Notification.Name("DataUpdateCompleted"), object: nil)
    }
    
    func triggerARCUpdate() {
        NotificationCenter.default.post(name: Notification.Name("ARCDataUpdated"), object: nil)
    }
    
    func triggerPassportUpdate() {
        NotificationCenter.default.post(name: Notification.Name("PassportDataUpdated"), object: nil)
    }
    
    func triggerMyInfoUpdate() {
        NotificationCenter.default.post(name: Notification.Name("MyInfoDataUpdated"), object: nil)
    }
    
    // Method to reset update flags
    func resetUpdateFlags() {
        dataUpdated = false
        arcDataUpdated = false
        passportDataUpdated = false
        myInfoDataUpdated = false
    }
    
    // Method to check if all data is updated
    func areAllDataUpdated() -> Bool {
        return arcDataUpdated && passportDataUpdated && myInfoDataUpdated
    }
}

// Extension for SwiftUI preview support
extension DataUpdateManager {
    static var preview: DataUpdateManager {
        let manager = DataUpdateManager()
        // Set up preview data here if needed
        return manager
    }
}
