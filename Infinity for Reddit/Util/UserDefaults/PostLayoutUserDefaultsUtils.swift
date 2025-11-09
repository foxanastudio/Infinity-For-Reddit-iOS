//
//  PostLayoutUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-09.
//

import Foundation

enum PostLayoutUserDefaultsUtils {
    static let frontPageKey = "post_layout_front_page"
    static var frontPage: PostLayout {
        return PostLayout(rawValue: UserDefaults.postLayout?.integer(forKey: frontPageKey, InterfacePostUserDefaultsUtils.defaultPostLayout) ?? PostLayout.card.rawValue) ?? PostLayout.card
    }
    static func saveFrontPage(_ newValue: PostLayout) {
        UserDefaults.postLayout?.set(newValue.rawValue, forKey: frontPageKey)
    }
    
    static let subredditKeyBase = "post_layout_subreddit_"
    static func getSubreddit(_ subredditName: String) -> PostLayout {
        return PostLayout(rawValue: UserDefaults.postLayout?.integer(forKey: "\(subredditKeyBase)\(subredditName)", InterfacePostUserDefaultsUtils.defaultPostLayout) ?? PostLayout.card.rawValue) ?? PostLayout.card
    }
    static func saveSubreddit(_ subredditName: String, _ newValue: PostLayout) {
        UserDefaults.postLayout?.set(newValue.rawValue, forKey: "\(subredditKeyBase)\(subredditName)")
    }
    
    static let customFeedKeyBase = "post_layout_custom_feed_"
    static func getCustomFeed(_ path: String) -> PostLayout {
        return PostLayout(rawValue: UserDefaults.postLayout?.integer(forKey: "\(customFeedKeyBase)\(path)", InterfacePostUserDefaultsUtils.defaultPostLayout) ?? PostLayout.card.rawValue) ?? PostLayout.card
    }
    static func saveCustomFeed(_ path: String, _ newValue: PostLayout) {
        UserDefaults.postLayout?.set(newValue.rawValue, forKey: "\(customFeedKeyBase)\(path)")
    }
    
    static let userKeyBase = "post_layout_user_"
    static func getUser(_ username: String) -> PostLayout {
        return PostLayout(rawValue: UserDefaults.postLayout?.integer(forKey: "\(userKeyBase)\(username)", InterfacePostUserDefaultsUtils.defaultPostLayout) ?? PostLayout.card.rawValue) ?? PostLayout.card
    }
    static func saveUser(_ username: String, _ newValue: PostLayout) {
        UserDefaults.postLayout?.set(newValue.rawValue, forKey: "\(userKeyBase)\(username)")
    }
    
    static let searchKey = "post_layout_search"
    static var search: PostLayout {
        return PostLayout(rawValue: UserDefaults.postLayout?.integer(forKey: searchKey, InterfacePostUserDefaultsUtils.defaultPostLayout) ?? PostLayout.card.rawValue) ?? PostLayout.card
    }
    static func saveSearch(_ newValue: PostLayout) {
        UserDefaults.postLayout?.set(newValue.rawValue, forKey: searchKey)
    }
    
    static let historyKey = "post_layout_history"
    static var history: PostLayout {
        return PostLayout(rawValue: UserDefaults.postLayout?.integer(forKey: historyKey, InterfacePostUserDefaultsUtils.defaultPostLayout) ?? PostLayout.card.rawValue) ?? PostLayout.card
    }
    static func saveHistory(_ newValue: PostLayout) {
        UserDefaults.postLayout?.set(newValue.rawValue, forKey: historyKey)
    }
}
