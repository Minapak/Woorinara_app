//
//  BannerAd.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 25.12.2023.
//


import SwiftUI
import GoogleMobileAds
import UIKit

private struct BannerVC: UIViewControllerRepresentable {
    var bannerID: String
    var width: CGFloat

    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width))

        let viewController = UIViewController()
        #if DEBUG
        view.adUnitID = "ca-app-pub-3940256099942544/6300978111"
        #else
        view.adUnitID = bannerID
        #endif
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        view.load(GADRequest())

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct Banner: View {
    var bannerID: String
    var width: CGFloat

    var size: CGSize {
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width).size
    }

    var body: some View {
        BannerVC(bannerID: bannerID, width: width)
            .frame(width: size.width, height: size.height)
    }
}

struct AdsHelper: View {
    var body: some View {
        Banner(bannerID: "ca-app-pub-3940256099942544/6300978111", width: UIScreen.main.bounds.width)
    }
}

struct AdsHelper_Previews: PreviewProvider {
    static var previews: some View {
        AdsHelper()
    }
}
