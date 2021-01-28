//
//  MVCustomSchemeHandler.swift
//  mv_to_ios
//
//  Created by mac-user on 2020/06/21.
//  Copyright © 2020 developer. All rights reserved.
//

import Foundation
import WebKit

enum MVCustomSchemeHandlerError: Error {
    case notFound(filename: String)
}

class MVCustomSchemeHandler: NSObject, WKURLSchemeHandler {
    static let MVScheme = "rpgmv"
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let url = urlSchemeTask.request.url!
        let urlString = url.absoluteString
        let file = urlString.replacingOccurrences(of: "rpgmv:///", with: "")
        let path = (file as NSString).deletingPathExtension
        let ext = (file as NSString).pathExtension
        
        guard let bundleUrl = Bundle.main.url(forResource: path, withExtension: ext, subdirectory: "htmlSource") else {
            urlSchemeTask.didFailWithError(MVCustomSchemeHandlerError.notFound(filename: "\(file)"))
            return
        }
        
        do {
            let data = try Data(contentsOf: bundleUrl)
            let mineType = getMineType(ext: ext)
            let commonHeaders: [String: String] = [
                "Content-Type": "\(mineType); charset=utf-8"
            ]
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: commonHeaders)
            
            urlSchemeTask.didReceive(response!)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        } catch {
            urlSchemeTask.didFailWithError(error)
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    }
    
    func getMineType(ext: String) -> String {
        if (ext == "html" || ext == "HTML") {
            return "text/html"
        }
        if (ext == "css" || ext == "CSS") {
            return "text/css"
        }
        if (ext == "ttf" || ext == "TTF") {
            return "font/ttf"
        }
        if (ext == "otf" || ext == "OTF") {
            return "font/otf"
        }
        if (ext == "woff" || ext == "WOFF") {
            return "font/woff"
        }
        if (ext == "js" || ext == "JS") {
            return "text/javascript"
        }
        if (ext == "json" || ext == "JSON") {
            return "application/json"
        }
        if (ext == "png" || ext == "PNG") {
            return "image/png"
        }
        if (ext == "jpg" || ext == "JPG" || ext == "jpeg" || ext == "JPEG") {
            return "image/jpeg"
        }
        if (ext == "m4a" || ext == "M4A") {
            return "audio/m4a"
        }
        if (ext == "oga" || ext == "OGA" || ext == "ogg" || ext == "OGG") {
            return "audio/ogg"
        }
        if (ext == "wasm" || ext == "WASM") {
            return "application/wasm"
        }
        if (ext == "txt" || ext == "TXT") {
            return "text/plain"
        }
        return "application/octet-stream"
    }
}
