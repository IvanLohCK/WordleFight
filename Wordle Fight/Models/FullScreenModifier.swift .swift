//
//  FullScreenModifier.swift .swift
//  Wordle Fight
//
//  Created by Ivan Loh on 14/3/22.
//

import Foundation
import SwiftUI
import GoogleMobileAds
import UIKit

struct FullScreenModifier<Parent: View>: View {
    @Binding var isPresented: Bool
    @State var adType: AdType
    
    //Select adType
    enum AdType {
        case interstitial
        case rewarded
    }
    
    var rewardFunc: () -> Void
    var adUnitId: String
  
    //The parent is the view that you are presenting over
    //Think of this as your presenting view controller
    var parent: Parent
    
    var body: some View {
        ZStack {
            parent
            
            if isPresented {
                EmptyView()
                    .edgesIgnoringSafeArea(.all)
                
                if adType == .rewarded {
                    RewardedAdView(isPresented: $isPresented, adUnitId: adUnitId, rewardFunc: rewardFunc)
                        .edgesIgnoringSafeArea(.all)
                } else if adType == .interstitial {
                    InterstitialAdView(isPresented: $isPresented, adUnitId: adUnitId)
                }
            }
        }
        .onAppear {
            //Initialize the ads as soon as the view appears
            if adType == .rewarded {
                RewardedAd.shared.loadAd(withAdUnitId: adUnitId)
            } else if adType == .interstitial {
                InterstitialAd.shared.loadAd(withAdUnitId: adUnitId)
            }
        }
    }
}

extension View {
    public func presentRewardedAd(isPresented: Binding<Bool>, adUnitId: String, rewardFunc: @escaping (() -> Void)) -> some View {
           FullScreenModifier(isPresented: isPresented, adType: .rewarded, rewardFunc: rewardFunc, adUnitId: adUnitId, parent: self)
   }
    
    public func presentInterstitialAd(isPresented: Binding<Bool>, adUnitId: String) -> some View {
        FullScreenModifier(isPresented: isPresented, adType: .interstitial, rewardFunc: {}, adUnitId: adUnitId, parent: self)
    }
}
