//
//  ViewController.swift
//  mv_to_ios
//
//  Created by mac-user on 2020/06/21.
//  Copyright © 2020 developer. All rights reserved.
//

import UIKit
import WebKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

class ViewController: UIViewController {
    
    private var webView: WKWebView!
    private var scriptHandler: ScriptHandler!
    private var bannerView: GADBannerView!
    private var isLoadedBanner = false
    private var isLoadedWebView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        if (isLoadedWebView) {
            return
        }
        
        createBannerView()
        createWebview()
        let url = URL(string: "rpgmv:///index.html")!
        webView.load(URLRequest(url:url))
        isLoadedWebView = true
        
        checkTrackingAuthorization()
        
        Advertisement.shared.loadRewardedAd(onLoaded: nil, onFailed: nil)
        Advertisement.shared.loadInterstitialAd()
        
        if !Constants.handleAdBannerDisplay {
            loadBanner()
        }
    }
        
    //MARK: - WebView
    
    func getWebviewFrame() -> CGRect {
        let screenWidth:CGFloat = view.frame.size.width
        var screenHeight:CGFloat = view.frame.size.height
        var window = UIWindow()
        for win in UIApplication.shared.windows {
            if win.isKeyWindow {
                window = win
            }
        }
        let topPadding = window.safeAreaInsets.top
        let bottomPadding = window.safeAreaInsets.bottom
        
        screenHeight = screenHeight - topPadding - bottomPadding
        var y:CGFloat = topPadding
        let bannerViewSize = getAdSize()
        if bannerView != nil {
            screenHeight -= bannerViewSize.size.height
            if Constants.adBannerPosition == "top" {
                y += bannerViewSize.size.height
            }
        }
        
        let rect = CGRect(x: 0, y: y, width: screenWidth, height: screenHeight)
        
        return rect
    }
    
    func createWebview() {
        if webView != nil {
            webView.removeFromSuperview()
        }
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(MVCustomSchemeHandler(), forURLScheme: "rpgmv")
        
        // scriptHandler
        scriptHandler = ScriptHandler()
        config.userContentController = scriptHandler.setUserContentController()
        
        self.webView = WKWebView(frame: getWebviewFrame(), configuration: config)
        self.view.addSubview(self.webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = true
        self.webView.scrollView.bounces = false
        scriptHandler.setWebView(_webView: self.webView)
        scriptHandler.setViewController(_viewController: self)
    }
    
    //MARK: - BannerView
    
    func getAdSize() -> GADAdSize {
        let frame = { () -> CGRect in
            if #available(iOS 11.0, *) {
                return view.frame.inset(by: view.safeAreaInsets)
            } else {
                return view.frame
            }
        }()
        let viewWidth = frame.size.width
        let adSize:GADAdSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        return adSize
    }
    
    func createBannerView() {
        if bannerView != nil {
            bannerView.removeFromSuperview()
        }
        if Constants.adBannerUnitId.isEmpty {
            bannerView = nil
            return
        }
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = Constants.adBannerUnitId
        bannerView.rootViewController = self
        bannerView.adSize = getAdSize()
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        let attribute = (Constants.adBannerPosition == "top") ? NSLayoutConstraint.Attribute.top : NSLayoutConstraint.Attribute.bottom
        
        view.addConstraints([
            NSLayoutConstraint(item: bannerView!,
                               attribute: attribute,
                               relatedBy: .equal,
                               toItem: view.safeAreaLayoutGuide,
                               attribute: attribute,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: bannerView!,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .centerX,
                               multiplier: 1,
                               constant: 0),
        ])
    }
    
    func loadBanner() {
        if bannerView == nil || isLoadedBanner {
            return
        }
        bannerView.load(GADRequest())
        isLoadedBanner = true
    }
    
    func checkTrackingAuthorization() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization( completionHandler: { status in
                switch status {
                case .authorized:
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                    print("requestTrackingAuthorization = authorized")
                case .notDetermined:
                    print("requestTrackingAuthorization = notDetermined")
                case .restricted:
                    print("requestTrackingAuthorization = restricted")
                case .denied:
                    print("requestTrackingAuthorization = denied")
                @unknown default:
                    fatalError()
                }
            })
        } else {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        }
    }
    
}
