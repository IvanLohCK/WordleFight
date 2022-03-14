//
//  RewardedAdObject .swift
//  Wordle Fight
//
//  Created by Ivan Loh on 14/3/22.
//

import SwiftUI
import GoogleMobileAds
import UIKit

class RewardedAd: NSObject {
    var rewardedAd: GADRewardedAd?
    
    static let shared = RewardedAd()
    
    func loadAd(withAdUnitId id: String) {
        let req = GADRequest()
        GADRewardedAd.load(withAdUnitID: id, request: req) { rewardedAd, err in
            if let err = err {
                print("Failed to load ad with error: \(err)")
                return
            }
            
            self.rewardedAd = rewardedAd
        }
    }
}
