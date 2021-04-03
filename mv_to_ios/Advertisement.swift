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
    
    private enum AdType: NSInteger {
        case unknown
        case rewardedAd
        case interstitialAd
    }
    private var adType = AdType.unknown
    
    private var interstitial: GADInterstitialAd?
    private var isInterstitialLoading: Bool = false
    private var isSucceededInterstitialAd: Bool = false
    private var showInterstitialAdOnSucceeded: (() -> Void)?
    private var showInterstitialAdOnFailed: (() -> Void)?
    
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
        adType = .rewardedAd
        
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
        print("adDidPresentFullScreenContent", adType)
        if adType == .interstitialAd {
            self.isSucceededInterstitialAd = true
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("adDidDismissFullScreenContent", adType)
        if adType == .rewardedAd {
            self.loadRewardedAd(onLoaded: nil, onFailed: nil)
            if isRewarded == true {
                self.showRewardedAdOnRewarded?()
            } else {
                self.showRewardedAdOnCanceled?()
            }
            return
        }
        if adType == .interstitialAd {
            self.loadInterstitialAd()
            if isSucceededInterstitialAd {
                self.showInterstitialAdOnSucceeded?()
            } else {
                self.showInterstitialAdOnFailed?()
            }
        }
        
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("didFailToPresentFullScreenContentWithError","[\(adType)]:\(error.localizedDescription).")
        if adType == .rewardedAd {
            self.showRewardedAdOnFailed?()
            return
        }
        if adType == .interstitialAd {
            self.showInterstitialAdOnFailed?()
        }
    }
    
    //=============================================================================
    // MARK: InterstitialAd
    //=============================================================================
    func loadInterstitialAd() {
        if (Constants.adInterstitialId == "") {
            return
        }
        
        isInterstitialLoading = true
        GADInterstitialAd.load(withAdUnitID: Constants.adInterstitialId, request: GADRequest())
        { (ad, error) in
            self.isInterstitialLoading = false
            if let error = error {
                print("loadInterstitialAd", "Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            print("loadInterstitialAd", "onAdLoaded")
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
        
        print("loadInterstitialAd", "Request Load")
    }
    
    func showInterstitialAd(viewController: UIViewController, onSucceeded: (() -> Void)?, onFailed: (() -> Void)?) {
        isSucceededInterstitialAd = false
        adType = .interstitialAd
        
        if let ad = interstitial {
            self.showInterstitialAdOnSucceeded = onSucceeded
            self.showInterstitialAdOnFailed = onFailed
            
            ad.present(fromRootViewController: viewController)
        } else {
            print("showInterstitialAd", "The rewarded ad wasn't ready yet.")
            
            if !isLoading {
                self.loadInterstitialAd()
            }
            onFailed?()
            return
        }
    }
    
}
