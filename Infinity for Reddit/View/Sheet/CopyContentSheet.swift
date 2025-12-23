//
//  CopyContentSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-26.
//

import SwiftUI
import WebKit

struct CopyContentSheet: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontFamilyKey, store: .interfaceFont) private var contentFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontScaleKey, store: .interfaceFont) private var contentFontScale: Int = 2
    
    let content: String
    
    var textColor: String? {
        return Color(hex: customThemeViewModel.currentCustomTheme.primaryTextColor).toHexString()
    }
    
    var html: String {
        return """
               <head>
               <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>
               <style>
                           body {
                               color: \(textColor ?? "#000000");
                               font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                           }
                       </style>
               </head>
               """ + content
    }
    
    var body: some View {
        SheetRootView {
            HTMLStringView(
                content: html,
                tintColor: UIColor(Color(hex: customThemeViewModel.currentCustomTheme.linkColor))
            )
        }
        .padding(16)
    }
}

struct HTMLStringView: UIViewRepresentable {
    let content: String
    let tintColor: UIColor

    func makeUIView(context: Context) -> WKWebView {
        let wv = WKWebView()
        wv.tintColor = tintColor
        wv.isOpaque = false
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(content, baseURL: nil)
        uiView.tintColor = tintColor
    }
}
