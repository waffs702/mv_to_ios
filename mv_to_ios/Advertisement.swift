//
//  Advertisement.swift
//  mv_to_ios
//
//  Created by mac-user on 2021/01/29.
//  Copyright © 2021 developer. All rights reserved.
//

import Foundation
import GoogleMobileAds

class Advertisement: NSObject, GADFullScreenContentDelegate {
    
    public static let shared = Advertisement()
    
    private var rewardedAd: GADRewardedAd?
    private var isRewarded: Bool = false
    private var isLoading: Bool = false
    private var showRewardedAdOnRewarded: (() -> Void)?
    private var showRewardedAdOnCanceled: (() -> Void)?
    private var showRewardedAdOnFailed: (() -> Void)?
    
    override private init() {}
    
    static func initAd() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    //=============================================================================
    // MARK: RewardedAd
    //=============================================================================
    func loadRewardedAd(onLoaded: (() -> Void)?, onFailed: (() -> Void)?) {
        if (Constants.adRewardedUnitId == "") {
            return
        }
        
        self.isLoading = true
        GADRewardedAd.load(withAdUnitID: Constants.adRewardedUnitId, request: GADRequest()
        ) { (ad, error) in
            self.isLoading = false
            if let error = error {
                print("loadRewardedAd", "Rewarded ad failed to load with error: \(error.localizedDescription)")
                onFailed?()
                return
            }
            print("loadRewardedAd", "onAdLoaded")
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            onLoaded?()
        }
    }
    
    func showRewardedAd(viewContorller: UIViewController, onRewarded: (() -> Void)?, onCanceled: (() -> Void)?, onFailed: (() -> Void)?) {
        isRewarded = false
        if let ad = rewardedAd {
            self.showRewardedAdOnRewarded = onRewarded
            self.showRewardedAdOnCanceled = onCanceled
            self.showRewardedAdOnFailed = onFailed
            
            ad.present(fromRootViewController: viewContorller) {
                let reward = ad.adReward
                print("showRewardedAd", "Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
                self.isRewarded = true
            }
        } else {
            print("showRewardedAd", "The rewarded ad wasn't ready yet.")
            
            if !isLoading {
                self.loadRewardedAd(onLoaded: nil, onFailed: nil)
            }
            onFailed?()
            return
        }
    }
    
    // MARK: GADFullScreenContentDelegate
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Rewarded ad presented.")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Rewarded ad dismissed.")
        self.loadRewardedAd(onLoaded: nil, onFailed: nil)
        if isRewarded == true {
            self.showRewardedAdOnRewarded?()
        } else {
            self.showRewardedAdOnCanceled?()
        }
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Rewarded ad failed to present with error: \(error.localizedDescription).")
        self.showRewardedAdOnFailed?()
    }
}
