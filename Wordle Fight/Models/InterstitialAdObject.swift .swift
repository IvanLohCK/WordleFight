//
//  InterstitialAdObject.swift .swift
//  Wordle Fight
//
//  Created by Ivan Loh on 14/3/22.
//

import SwiftUI
import GoogleMobileAds
import UIKit

class InterstitialAd: NSObject {
    var interstitialAd: GADInterstitialAd?
    
    //Want to have one instance of the ad for the entire app
    //We can do this b/c you will never show more than 1 ad at once so only 1 ad needs to be loaded
    static let shared = InterstitialAd()
    
    func loadAd(withAdUnitId id: String) {
        let req = GADRequest()
        GADInterstitialAd.load(withAdUnitID: id, request: req) { interstitialAd, err in
            if let err = err {
                print("Failed to load ad with error: \(err)")
                return
            }
            
            self.interstitialAd = interstitialAd
        }
    }
}
