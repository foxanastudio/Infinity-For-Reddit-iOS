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
        let enabled = UserDefaults.standard.bool(forKey: safariAppExtensionOpenInInfinityEnabledKey, false)
        if type == "getEnabled" {
            response.userInfo = [ SFExtensionMessageKey: [ "enabled":  enabled ] ]
        } else if type == "toggleEnabled" {
            UserDefaults.standard.set(!enabled, forKey: safariAppExtensionOpenInInfinityEnabledKey)
            response.userInfo = [ SFExtensionMessageKey: [ "enabled":  !enabled ] ]
        }
        
        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
}

extension UserDefaults {
    func bool(forKey key: String, _ defaultValue: Bool) -> Bool {
        object(forKey: key) == nil ? defaultValue : bool(forKey: key)
    }
}
