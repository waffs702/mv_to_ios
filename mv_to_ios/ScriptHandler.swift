//
//  ScriptHandler.swift
//  mv_to_ios
//
//  Created by mac-user on 2021/01/28.
//  Copyright © 2021 developer. All rights reserved.
//

import Foundation
import WebKit

class ScriptHandler: NSObject, WKScriptMessageHandler {
    private var webView: WKWebView!
    
    func setWebView(_webView: WKWebView) {
        webView = _webView
    }
    
    func setUserContentController() -> WKUserContentController {
        let userContentController = WKUserContentController()
        
        userContentController.add(self, name: "debugLog")
        userContentController.add(self, name: "initAd")
        userContentController.add(self, name: "loadRewardedAd")
        userContentController.add(self, name: "showRewardedAd")
        
        return userContentController
    }
    
    func callbackToJavascript(args: String, key: String) {
        webView.evaluateJavaScript("window.MVZxNativeManager.nativeCallback('\(args)', '\(key)');", completionHandler: nil)
    }
    
    func debugLog(log: String) {
        print(log)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "debugLog":
            debugLog(log: message.body as! String)
        default:
            print("default")
        }
    }
    
    
}


