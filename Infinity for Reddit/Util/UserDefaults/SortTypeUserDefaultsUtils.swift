//
//  SortTypeUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-17.
//

import Foundation

enum SortTypeUserDetailsUtils {
    static let frontPagePostSortTypeKey = "best_post_sort_type"
    static let frontPagePostSortTimeKey = "best_post_sort_time"
    static var frontPagePost: SortType {
        let sortTypeKind = SortType.Kind(rawValue: UserDefaults.sortType?.string(forKey: frontPagePostSortTypeKey) ?? SortType.Kind.best.rawValue) ?? SortType.Kind.best
        if sortTypeKind.hasTime {
            let sortTypeTime = SortType.Time(rawValue: UserDefaults.sortType?.string(forKey: frontPagePostSortTimeKey) ?? SortType.Time.all.rawValue) ?? SortType.Time.all
            return .init(type: sortTypeKind, time: sortTypeTime)
        } else {
            return .init(type: sortTypeKind)
        }
    }
    
    static let searchPostSortTypeKey = "search_post_sort_type"
    static let searchPostSortTimeKey = "search_post_sort_time"
    static var searchPost: SortType {
        let sortTypeKind = SortType.Kind(rawValue: UserDefaults.sortType?.string(forKey: searchPostSortTypeKey) ?? SortType.Kind.relevance.rawValue) ?? SortType.Kind.relevance
        if sortTypeKind.hasTime {
            let sortTypeTime = SortType.Time(rawValue: UserDefaults.sortType?.string(forKey: searchPostSortTimeKey) ?? SortType.Time.all.rawValue) ?? SortType.Time.all
            return .init(type: sortTypeKind, time: sortTypeTime)
        } else {
            return .init(type: sortTypeKind)
        }
    }

    static let subredditPostSortTypeBaseKey = "subreddit_post_sort_type_"
    static let subredditPostSortTimeBaseKey = "subreddit_post_sort_time_"
    static func getSubredditPost(subredditName: String) -> SortType {
        let sortTypeKind = SortType.Kind(rawValue: UserDefaults.sortType?.string(forKey: subredditPostSortTypeBaseKey + subredditName) ?? SortTypeSettingsUserDefaultsUtils.subredditDefaultSortType) ?? SortType.Kind.hot
        if sortTypeKind.hasTime {
            let sortTypeTime = SortType.Time(rawValue: UserDefaults.sortType?.string(forKey: subredditPostSortTimeBaseKey + subredditName) ?? SortTypeSettingsUserDefaultsUtils.subredditDefaultSortTime) ?? SortType.Time.all
            return .init(type: sortTypeKind, time: sortTypeTime)
        } else {
            return .init(type: sortTypeKind)
        }
    }

    static let customFeedPostSortTypeBaseKey = "custom_feed_post_sort_type_"
    static let customFeedPostSortTimeBaseKey = "custom_feed_post_sort_time_"
    static func getCustomFeedPost(path: String) -> SortType {
        let sortTypeKind = SortType.Kind(rawValue: UserDefaults.sortType?.string(forKey: customFeedPostSortTypeBaseKey + path) ?? SortType.Kind.hot.rawValue) ?? SortType.Kind.hot
        if sortTypeKind.hasTime {
            let sortTypeTime = SortType.Time(rawValue: UserDefaults.sortType?.string(forKey: customFeedPostSortTimeBaseKey + path) ?? SortType.Time.all.rawValue) ?? SortType.Time.all
            return .init(type: sortTypeKind, time: sortTypeTime)
        } else {
            return .init(type: sortTypeKind)
        }
    }

    static let userPostSortTypeBaseKey = "user_post_sort_type_"
    static let userPostSortTimeBaseKey = "user_post_sort_time_"
    static func getUserPost(username: String) -> SortType {
        let sortTypeKind = SortType.Kind(rawValue: UserDefaults.sortType?.string(forKey: userPostSortTypeBaseKey + username) ?? SortTypeSettingsUserDefaultsUtils.userDefaultSortType) ?? SortType.Kind.new
        if sortTypeKind.hasTime {
            let sortTypeTime = SortType.Time(rawValue: UserDefaults.sortType?.string(forKey: userPostSortTimeBaseKey + username) ?? SortTypeSettingsUserDefaultsUtils.userDefaultSortTime) ?? SortType.Time.all
            return .init(type: sortTypeKind, time: sortTypeTime)
        } else {
            return .init(type: sortTypeKind)
        }
    }

    static let userCommentSortTypeKey = "user_comment_sort_type"
    static let userCommentSortTimeKey = "user_comment_sort_time"
    static func getUserComment(username: String) -> SortType {
        let sortTypeKind = SortType.Kind(rawValue: UserDefaults.sortType?.string(forKey: userCommentSortTypeKey + username) ?? SortType.Kind.new.rawValue) ?? SortType.Kind.new
        if sortTypeKind.hasTime {
            let sortTypeTime = SortType.Time(rawValue: UserDefaults.sortType?.string(forKey: userCommentSortTimeKey + username) ?? SortType.Time.all.rawValue) ?? SortType.Time.all
            return .init(type: sortTypeKind, time: sortTypeTime)
        } else {
            return .init(type: sortTypeKind)
        }
    }

    static let subredditListingSortTypeKey = "subreddit_listing_sort_type"
    static var subredditListing: SortType.Kind {
        let sortTypeKind = SortType.Kind(rawValue: UserDefaults.sortType?.string(forKey: subredditListingSortTypeKey) ?? SortType.Kind.relevance.rawValue) ?? SortType.Kind.relevance
        return sortTypeKind
    }
    
    static let userListingSortTypeKey = "user_listing_sort_type"
    static var userListing: SortType.Kind {
        let sortTypeKind = SortType.Kind(rawValue: UserDefaults.sortType?.string(forKey: userListingSortTypeKey) ?? SortType.Kind.relevance.rawValue) ?? SortType.Kind.relevance
        return sortTypeKind
    }
    
    static let postCommentSortTypeKey = "post_comment_sort_type"
    static var postComment: SortType.Kind {
        let sortTypeKind = SortType.Kind(rawValue: UserDefaults.sortType?.string(forKey: postCommentSortTypeKey) ?? SortType.Kind.best.rawValue) ?? SortType.Kind.best
        return sortTypeKind
    }
}
