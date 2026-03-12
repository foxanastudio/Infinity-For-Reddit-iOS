//
//  PostHistoryUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-11.
//

import Foundation

enum PostHistoryUserDefaultsUtils {
    static let saveReadPostsKey = "save_read_posts"
    static var saveReadPosts: Bool {
        return UserDefaults.postHistory.bool(forKey: saveReadPostsKey)
    }
    
    static let limitHistorySizeKey = "limit_history_size"
    static var limitHistorySize: Bool {
        return UserDefaults.postHistory.bool(forKey: limitHistorySizeKey)
    }
    
    static let historyLimitKey = "history_limit"
    static var historyLimit: Int {
        return UserDefaults.postHistory.integer(forKey: historyLimitKey)
    }
    
    static let markPostsAsReadAfterVotingKey = "mark_posts_as_read_after_voting"
    static var markPostsAsReadAfterVoting: Bool {
        return UserDefaults.postHistory.bool(forKey: markPostsAsReadAfterVotingKey)
    }
    
    static let markPostsAsReadOnScrollKey = "mark_posts_as_read_on_scroll"
    static var markPostsAsReadOnScroll: Bool {
        return UserDefaults.postHistory.bool(forKey: markPostsAsReadOnScrollKey)
    }
    
    static let hideReadPostsKey = "hide_read_posts"
    static var hideReadPosts: Bool {
        return UserDefaults.postHistory.bool(forKey: hideReadPostsKey)
    }
}
