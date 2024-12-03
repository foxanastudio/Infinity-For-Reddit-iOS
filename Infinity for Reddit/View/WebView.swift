//
//  WebView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-01.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    let urlChangeListener: ((String) -> Void)?
    
    func makeUIView(context: Context) -> WKWebView {
        let wKWebView = WKWebView()
        //clean()
        wKWebView.navigationDelegate = context.coordinator
        return wKWebView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(self)
    }
    
    func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    class WebViewCoordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let urlStr = navigationAction.request.url?.absoluteString {
                if let urlChangeListener = parent.urlChangeListener {
                    urlChangeListener(urlStr)
                }
            }
            decisionHandler(.allow)
        }
    }
}
