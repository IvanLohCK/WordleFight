//
//  RewardedAdView.swift
//  Wordle Fight
//
//  Created by Ivan Loh on 14/3/22.
//

import SwiftUI
import GoogleMobileAds
import UIKit

final class RewardedAdView: NSObject, UIViewControllerRepresentable, GADFullScreenContentDelegate {
    
    let rewardedAd = RewardedAd.shared.rewardedAd
    @Binding var isPresented: Bool
    let adUnitId: String
  
    //This is the variable for our reward function
    let rewardFunc: (() -> Void)
    
    init(isPresented: Binding<Bool>, adUnitId: String, rewardFunc: @escaping (() -> Void)) {
        self._isPresented = isPresented
        self.adUnitId = adUnitId
        self.rewardFunc = rewardFunc
        
        super.init()
        
        rewardedAd?.fullScreenContentDelegate = self
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let view = UIViewController()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            self.showAd(from: view)
        }
        
        return view
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    func showAd(from root: UIViewController) {
        
        if let ad = rewardedAd {
            ad.present(fromRootViewController: root) {
                //This calls the reward function once the ad has been played for long enough
                self.rewardFunc()
            }
        } else {
            print("Ad not ready")
            self.isPresented.toggle()
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        RewardedAd.shared.loadAd(withAdUnitId: adUnitId)
        
        isPresented.toggle()
    }
}
