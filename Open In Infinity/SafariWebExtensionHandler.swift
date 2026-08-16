//
//  SafariWebExtensionHandler.swift
//  Open In Infinity
//
//  Created by Docile Alligator on 2026-05-12.
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    private let safariAppExtensionOpenInInfinityEnabledKey = "safari_app_extension_open_in_infinity_enabled"
    
    func beginRequest(with context: NSExtensionContext) {
        guard let item = context.inputItems.first as? NSExtensionItem,
              let userInfo = item.userInfo as? [String: Any],
              let message = userInfo[SFExtensionMessageKey] as? [String: String],
              let type = message["type"] else {
            context.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        
        let response = NSExtensionItem()
        let enabled = UserDefaults.standard.bool(forKey: safariAppExtensionOpenInInfinityEnabledKey, true)
        if type == "getEnabled" {
            response.userInfo = [ SFExtensionMessageKey: [ "enabled":  enabled ] ]
        } else if type == "toggleEnabled" {
            UserDefaults.standard.set(!enabled, forKey: safariAppExtensionOpenInInfinityEnabledKey)
            response.userInfo = [ SFExtensionMessageKey: [ "enabled":  !enabled ] ]
        } else if type == "checkIfCanHandle", let urlString = message["urlString"] {
            response.userInfo = [ SFExtensionMessageKey: [ "canHandle": canHandleRedditPath(urlString) ] ]
        }
        
        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
    
    private func canHandleRedditPath(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        
        let path = url.path
        let segments = path.split(separator: "/").map(String.init)
        
        if path == "/report" {
            return false
        } else if segments.count == 4 && (segments[0] == "r" || segments[0] == "u"), segments[2] == "s" {
            return true
        } else if segments.count == 4, segments[0] == "r", segments[2] == "wiki" {
            return true
        } else if segments.contains("comments"), let index = segments.lastIndex(of: "comments"), index + 1 < segments.count {
            return true
        } else if path == "/media", let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                  let realURLString = query.first(where: { $0.name == "url" })?.value,
                  let _ = URL(string: realURLString) {
            return true
        } else if segments.count == 4, segments[0] == "user", segments[2] == "m" {
            // Custom Feed
            return true
        } else if let subredditMatch = path.range(of: "/r/[\\w-]+", options: .regularExpression) {
            return true
        } else if let userMatch = path.range(of: "/(u|user)/[\\w-]+", options: .regularExpression) {
            return true
        } else {
            return false
        }
    }
}

extension UserDefaults {
    func bool(forKey key: String, _ defaultValue: Bool) -> Bool {
        object(forKey: key) == nil ? defaultValue : bool(forKey: key)
    }
}
