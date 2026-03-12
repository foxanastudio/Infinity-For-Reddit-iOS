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
    
    static let hideReadPostsAutomaticallyKey = "hide_read_posts_automatically"
    static var hideReadPostsAutomatically: Bool {
        return UserDefaults.postHistory.bool(forKey: hideReadPostsAutomaticallyKey)
    }
    
    static let hideReadPostsAutomaticallyInSubredditsKey = "hide_read_posts_automatically_in_subreddits"
    static var hideReadPostsAutomaticallyInSubreddits: Bool {
        return UserDefaults.postHistory.bool(forKey: hideReadPostsAutomaticallyInSubredditsKey)
    }
    
    static let hideReadPostsAutomaticallyInUsersKey = "hide_read_posts_automatically_in_users"
    static var hideReadPostsAutomaticallyInUsers: Bool {
        return UserDefaults.postHistory.bool(forKey: hideReadPostsAutomaticallyInUsersKey)
    }
    
    static let hideReadPostsAutomaticallyInSearchKey = "hide_read_posts_automatically_in_search"
    static var hideReadPostsAutomaticallyInSearch: Bool {
        return UserDefaults.postHistory.bool(forKey: hideReadPostsAutomaticallyInSearchKey)
    }
}
