//
//  ViewController.swift
//  mv_to_ios
//
//  Created by mac-user on 2020/06/21.
//  Copyright © 2020 developer. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    private var webView: WKWebView!
    private var scriptHandler: ScriptHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        // Do any additional setup after loading the view.
        
        self.createWebview()
        let url = URL(string: "rpgmv:///index.html")!
        self.webView.load(URLRequest(url:url))
        
        Advertisement.shared.loadRewardedAd(onLoaded: nil, onFailed: nil)
        Advertisement.shared.loadInterstitialAd()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }
        
    //MARK: - WebView
    
    func getWebviewFrame() -> CGRect {
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        var window = UIWindow()
        for win in UIApplication.shared.windows {
            if win.isKeyWindow {
                window = win
            }
        }
        let topPadding = window.safeAreaInsets.top
        let bottomPadding = window.safeAreaInsets.bottom
        
        let rect = CGRect(x: 0, y: topPadding * -1, width: screenWidth, height: screenHeight + topPadding - bottomPadding)
        
        return rect
    }
    
    func createWebview() {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(MVCustomSchemeHandler(), forURLScheme: "rpgmv")
        
        // scriptHandler
        scriptHandler = ScriptHandler()
        config.userContentController = scriptHandler.setUserContentController()
        
        self.webView = WKWebView(frame: getWebviewFrame(), configuration: config)
        self.view.addSubview(self.webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.scrollView.bounces = false
        scriptHandler.setWebView(_webView: self.webView)
        scriptHandler.setViewController(_viewController: self)
    }
    
}
