//
//  UpgradeViewModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 11.06.2023.
//

import Foundation
import SwiftUI
import RevenueCat


class UpgradeViewModel : ObservableObject{
  
//    @Published var isSubscriptionActive = UserDefaults.isProVersion
    @Published var isSubscriptionActive = UserDefaults.isProVersion
    @Published var isLoading = false
    
    private var firebaseViewModel = FirebaseViewModel()


    init() {
        
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            self.isSubscriptionActive = customerInfo?.entitlements.all[Constants.ENTITLEMENTS_ID]?.isActive == true
            self.firebaseViewModel.updateProVersion(isPro: self.isSubscriptionActive)
        }
    }

    func setThePurchaseStatus(isPro : Bool){
        self.isSubscriptionActive = isPro
        UserDefaults.isProVersion = isPro
        
        firebaseViewModel.updateProVersion(isPro: isPro)
    }
}
