//
//  SortTypeSettingsUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-05.
//

import Foundation

class SortTypeSettingsUserDefaultsUtils {
    static let saveSortTypeKey = "save_sort_type"
    static var saveSortType: Bool {
        return UserDefaults.sortTypeSettings.bool(forKey: saveSortTypeKey, true)
    }
    
    static let subredditDefaultSortTypeKey = "subreddit_default_sort_type"
    static var subredditDefaultSortType: String {
        return UserDefaults.sortTypeSettings.string(forKey: subredditDefaultSortTypeKey) ?? SortType.Kind.hot.rawValue
    }
    static let subredditSortTypes: [String] = ["hot", "new", "rising", "top", "controversial"]
    
    static let subredditDefaultSortTimeKey = "subreddit_default_sort_time"
    static var subredditDefaultSortTime: String {
        return UserDefaults.sortTypeSettings.string(forKey: subredditDefaultSortTimeKey) ?? SortType.Time.all.rawValue
    }
    static let sortTimes: [String] = ["hour", "day", "week", "month", "year", "all"]
    
    static let userDefaultSortTypeKey = "user_default_sort_type"
    static var userDefaultSortType: String {
        return UserDefaults.sortTypeSettings.string(forKey: userDefaultSortTypeKey) ?? SortType.Kind.new.rawValue
    }
    static let userSortTypes: [String] = ["new", "hot", "top", "controversial"]
    
    static let userDefaultSortTimeKey = "user_default_sort_time"
    static var userDefaultSortTime: String {
        return UserDefaults.sortTypeSettings.string(forKey: userDefaultSortTimeKey) ?? SortType.Time.all.rawValue
    }
    
    static let respectSubredditRecommendedCommentSortTypeKey = "respect_subreddit_recommended_comment_sort_type"
    static var respectSubredditRecommendedCommentSortType: Bool {
        return UserDefaults.sortTypeSettings.bool(forKey: respectSubredditRecommendedCommentSortTypeKey, false)
    }
}
