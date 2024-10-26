//
//  InterstitialAd.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 7.12.2023.
//


import SwiftUI
import GoogleMobileAds
import UIKit
    
#if DEBUG
let adUnitID = "ca-app-pub-3940256099942544/1033173712"
#else
let adUnitID = Constants.INTERSTITIAL_AD_UNIT_ID
#endif

final class Interstitial: NSObject, GADFullScreenContentDelegate {
    private var interstitial: GADInterstitialAd?
    
    override init() {
        super.init()
        loadInterstitial()
    }
    
    func loadInterstitial(){
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:adUnitID,
                                    request: request,
                          completionHandler: { [self] ad, error in
                            if let error = error {
                              print("Failed to load interstitial ad: \(error.localizedDescription)")
                              return
                            }
                            interstitial = ad
                            interstitial?.fullScreenContentDelegate = self
                          }
        )
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    /// Tells the delegate that the ad presented full screen content.

    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        loadInterstitial()
    }
    
    func showAd(){
        guard let root = UIApplication.shared.keyWindowPresentedController else {
            return
        }
        interstitial?.present(fromRootViewController: root)
    }
}
