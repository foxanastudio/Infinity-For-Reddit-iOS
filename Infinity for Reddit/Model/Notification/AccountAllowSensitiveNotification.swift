//
//  AccountAllowSensitiveNotification.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-03-19.
//

import Foundation

struct AccountAllowSensitiveNotification {
    static let name = Notification.Name.accountAllowSensitiveChanged
    
    static func post(allowSensitive: Bool) {
        NotificationCenter.default.post(
            name: name,
            object: nil,
            userInfo: ["value": allowSensitive]
        )
    }
    
    static func isAllowSensitive(_ notification: Notification) -> Bool {
        return notification.userInfo?["value"] as? Bool ?? false
    }
}
