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
    private var viewController: ViewController!
    
    func setWebView(_webView: WKWebView) {
        webView = _webView
    }
    
    func setViewController(_viewController: ViewController) {
        viewController = _viewController
    }
    
    func setUserContentController() -> WKUserContentController {
        let userContentController = WKUserContentController()
        
        userContentController.add(self, name: "debugLog")
        userContentController.add(self, name: "initAd")
        userContentController.add(self, name: "loadRewardedAd")
        userContentController.add(self, name: "showRewardedAd")
        userContentController.add(self, name: "showInterstitialAd")
        userContentController.add(self, name: "shareSNS")
        
        return userContentController
    }
    
    func callbackToJavascript(args: String, key: String) {
        webView.evaluateJavaScript("window.MVZxNativeManager.nativeCallback('\(args)', '\(key)');", completionHandler: nil)
    }
    
    func debugLog(log: String) {
        print(log)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body: String = message.body as! String
        let data = body.data(using: .utf8)!
        do {
            let params = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let callbackKey = params?["k"] as? String ?? ""
            print("userContentController", "message.name", message.name)
            switch message.name {
            case "debugLog":
                debugLog(log: body)
            case "initAd":
                initAd()
            case "loadRewardedAd":
                loadRewardedAd(callbackKey: callbackKey)
            case "showRewardedAd":
                showRewardedAd(callbackKey: callbackKey)
            case "showInterstitialAd":
                showInterstitialAd(callbackKey: callbackKey)
            case "shareSNS":
                let shareText = params?["t"] as? String ?? ""
                let shareImageBase64 = params?["i"] as? String ?? ""
                shareSNS(shareText: shareText, shareImageBase64: shareImageBase64)
            default:
                print("userContentController", "default")
            }
            
        } catch {
            print("userContentController error", error.localizedDescription)
        }
    }
    
    func initAd() {
        Advertisement.initAd()
    }
    
    func loadRewardedAd(callbackKey: String) {
        Advertisement.shared.loadRewardedAd {
            self.callbackToJavascript(args: "onLoaded", key: callbackKey)
        } onFailed: {
            self.callbackToJavascript(args: "onFailed", key: callbackKey)
        }
    }
    
    func showRewardedAd(callbackKey: String) {
        Advertisement.shared.showRewardedAd(viewContorller: self.viewController) {
            self.callbackToJavascript(args: "onRewarded", key: callbackKey)
        } onCanceled: {
            self.callbackToJavascript(args: "onCanceled", key: callbackKey)
        } onFailed: {
            self.callbackToJavascript(args: "onFailed", key: callbackKey)
        }
    }
    
    func showInterstitialAd(callbackKey: String) {
        Advertisement.shared.showInterstitialAd(viewController: self.viewController) {
            self.callbackToJavascript(args: "onSucceeded", key: callbackKey)
        } onFailed: {
            self.callbackToJavascript(args: "onFailed", key: callbackKey)
        }
    }
    
    func shareSNS(shareText: String, shareImageBase64: String) {
        var activityItems: Array<Any> = [shareText]
        
        if (shareImageBase64 != "") {
            let dataDecoded:NSData = NSData(base64Encoded: shareImageBase64, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
            activityItems += [decodedimage]
        }
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact
        ]
        self.viewController.present(activityViewController, animated: true, completion: nil)
    }
    
}


