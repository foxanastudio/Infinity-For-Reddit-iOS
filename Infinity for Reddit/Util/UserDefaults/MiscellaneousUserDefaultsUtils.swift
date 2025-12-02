//
//  MiscellaneousUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-02.
//

import Foundation

class MiscellaneousUserDefaultsUtils {
    static let saveLastSeenPostInFrontPageKey = "save_last_seen_post_in_front_page"
    static var saveLastSeenPostInFrontPage: Bool {
        return UserDefaults.miscellaneous.bool(forKey: saveLastSeenPostInFrontPageKey, false)
    }
    
    private static let frontPageBase = "front_page_"
    static func saveLastSeenPostInFrontPage(post: Post, account: Account) {
        UserDefaults.miscellaneous.set(post.name, forKey: frontPageBase + account.username)
    }
    static func getLastSeenPostInFrontPage(account: Account) -> String? {
        return UserDefaults.miscellaneous.string(forKey: frontPageBase + account.username)
    }
}
