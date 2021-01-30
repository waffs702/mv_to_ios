//
//  Advertisement.swift
//  mv_to_ios
//
//  Created by mac-user on 2021/01/29.
//  Copyright © 2021 developer. All rights reserved.
//

import Foundation
import GoogleMobileAds

class Advertisement: NSObject, GADRewardedAdDelegate {
    
    public static let shared = Advertisement()
    
    private var rewarededAd: GADRewardedAd?
    private var isRewarded: Bool = false
    private var isLoading: Bool = false
    private var showRewardedAdOnRewarded: (() -> Void)?
    private var showRewardedAdOnCanceled: (() -> Void)?
    private var showRewardedAdOnFailed: (() -> Void)?
    
    override private init() {}
    
    static func initAd() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    func loadRewardedAd(onLoaded: (() -> Void)?, onFailed: (() -> Void)?) {
        rewarededAd = GADRewardedAd(adUnitID: Constants.adRewardedUnitId)
        isLoading = true
        print("loadRewardedAd", "Request Load")
        rewarededAd?.load(GADRequest()) { error in
            self.isLoading = false
            if let error = error {
                print("loadRewardedAd", "onAdFailedToLoad : ", error)
                onFailed?()
            } else {
                print("loadRewardedAd", "onAdLoaded")
                onLoaded?()
            }
        }
    }
    
    func showRewardedAd(viewContorller: UIViewController, onRewarded: (() -> Void)?, onCanceled: (() -> Void)?, onFailed: (() -> Void)?) {
        isRewarded = false
        if rewarededAd?.isReady != true {
            print("showRewardedAd", "The rewarded ad wasn't ready yet.")
            
            if !isLoading {
                self.loadRewardedAd(onLoaded: nil, onFailed: nil)
            }
            onFailed?()
            return
        }
        
        self.showRewardedAdOnRewarded = onRewarded
        self.showRewardedAdOnCanceled = onCanceled
        self.showRewardedAdOnFailed = onFailed
        
        rewarededAd?.present(fromRootViewController: viewContorller, delegate: self)
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        isRewarded = true
    }

    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        print("Rewarded ad presented.")
    }

    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        print("Rewarded ad dismissed.")
        self.loadRewardedAd(onLoaded: nil, onFailed: nil)
        if isRewarded == true {
            self.showRewardedAdOnRewarded?()
        } else {
            self.showRewardedAdOnCanceled?()
        }
    }

    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        print("Rewarded ad failed to present.")
        self.showRewardedAdOnFailed?()
    }
}
