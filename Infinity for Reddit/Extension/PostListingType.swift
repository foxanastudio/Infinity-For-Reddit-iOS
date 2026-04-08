//
//  PostListingType.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-29.
//

import Foundation

extension PostListingType: SortTypeKindSource {
    var availableSortTypeKinds: [SortType.Kind] {
        switch self {
        case .frontPage:
            return [.best, .hot, .new, .rising, .top, .controversial]
        case .subreddit:
            return [.hot, .new, .rising, .top, .controversial]
        case .user:
            return [.new, .hot, .top, .controversial]
        case .search:
            return [.relevance, .hot, .top, .new, .comments]
        case .customFeed:
            return [.hot, .new, .rising, .top, .controversial]
        case .anonymousFrontPage:
            return [.hot, .new, .rising, .top, .controversial]
        case .anonymousCustomFeed:
            return [.hot, .new, .rising, .top, .controversial]
        }
    }
}

extension PostListingType: SortTypeTimeSource {
    var availableSortTypeTimes: [SortType.Time] {
        return [.hour, .day, .week, .month, .year, .all]
    }
}

extension PostListingType {
    var sortEmbeddingStyle: SortEmbeddingStyle {
        if case .user(_, let userWhere) = self {
            if userWhere == .submitted {
                return .inQuery(key: "sort")
            } else {
                return .none
            }
        } else {
            return .inPath
        }
    }
    
    var defaultSortTime: SortType.Time {
        return .day
    }
}

extension PostListingType {
    var canQuerySensitiveInAPICall: Bool {
        switch self {
        case .search:
            return true
        default:
            return false
        }
    }
}

extension PostListingType {
    var postFilterUsageType: PostFilterUsage.UsageType {
        switch self {
        case .frontPage:
            return .frontPage
        case .subreddit:
            return .subreddit
        case .user:
            return .user
        case .search:
            return .search
        case .customFeed:
            return .customFeed
        case .anonymousFrontPage:
            return .frontPage
        case .anonymousCustomFeed:
            return .customFeed
        }
    }
}

extension PostListingType {
    var postFilterNameOfUsage: String {
        switch self {
        case .frontPage:
            return PostFilterUsage.NO_USAGE
        case .subreddit(let subredditName):
            return subredditName
        case .user(let username, _):
            return username
        case .search:
            return PostFilterUsage.NO_USAGE
        case .customFeed(let path):
            return path
        case .anonymousFrontPage:
            return PostFilterUsage.NO_USAGE
        case .anonymousCustomFeed(let myCustomFeed, _):
            return myCustomFeed.path
        }
    }
}

extension PostListingType {
    var savedSortType: SortType {
        switch self {
        case .frontPage:
            return SortTypeUserDetailsUtils.frontPagePost
        case .subreddit(let subredditName):
            return SortTypeUserDetailsUtils.getSubredditPost(subredditName: subredditName)
        case .user(let username, _):
            return SortTypeUserDetailsUtils.getUserPost(username: username)
        case .search:
            return SortTypeUserDetailsUtils.searchPost
        case .customFeed(let path):
            return SortTypeUserDetailsUtils.getCustomFeedPost(path: path)
        case .anonymousFrontPage:
            return SortTypeUserDetailsUtils.getSubredditPost(subredditName: Account.ANONYMOUS_ACCOUNT.username)
        case .anonymousCustomFeed(let myCustomFeed, _):
            return SortTypeUserDetailsUtils.getCustomFeedPost(path: myCustomFeed.path)
        }
    }
    
    func saveSortType(sortType: SortType) {
        switch self {
        case .frontPage:
            UserDefaults.sortType?.set(sortType.type.rawValue, forKey: SortTypeUserDetailsUtils.frontPagePostSortTypeKey)
            if let time = sortType.time {
                UserDefaults.sortType?.set(time.rawValue, forKey: SortTypeUserDetailsUtils.frontPagePostSortTimeKey)
            }
        case .subreddit(let subredditName):
            UserDefaults.sortType?.set(sortType.type.rawValue, forKey: SortTypeUserDetailsUtils.subredditPostSortTypeBaseKey + subredditName)
            if let time = sortType.time {
                UserDefaults.sortType?.set(time.rawValue, forKey: SortTypeUserDetailsUtils.subredditPostSortTimeBaseKey + subredditName)
            }
        case .user(let username, _):
            UserDefaults.sortType?.set(sortType.type.rawValue, forKey: SortTypeUserDetailsUtils.userPostSortTypeBaseKey + username)
            if let time = sortType.time {
                UserDefaults.sortType?.set(time.rawValue, forKey: SortTypeUserDetailsUtils.userPostSortTimeBaseKey + username)
            }
        case .search:
            UserDefaults.sortType?.set(sortType.type.rawValue, forKey: SortTypeUserDetailsUtils.searchPostSortTypeKey)
            if let time = sortType.time {
                UserDefaults.sortType?.set(time.rawValue, forKey: SortTypeUserDetailsUtils.searchPostSortTimeKey)
            }
        case .customFeed(let path):
            UserDefaults.sortType?.set(sortType.type.rawValue, forKey: SortTypeUserDetailsUtils.customFeedPostSortTypeBaseKey + path)
            if let time = sortType.time {
                UserDefaults.sortType?.set(time.rawValue, forKey: SortTypeUserDetailsUtils.customFeedPostSortTimeBaseKey + path)
            }
        case .anonymousFrontPage:
            UserDefaults.sortType?.set(sortType.type.rawValue, forKey: SortTypeUserDetailsUtils.subredditPostSortTypeBaseKey + Account.ANONYMOUS_ACCOUNT.username)
            if let time = sortType.time {
                UserDefaults.sortType?.set(time.rawValue, forKey: SortTypeUserDetailsUtils.subredditPostSortTimeBaseKey + Account.ANONYMOUS_ACCOUNT.username)
            }
        case .anonymousCustomFeed(let myCustomFeed, _):
            UserDefaults.sortType?.set(sortType.type.rawValue, forKey: SortTypeUserDetailsUtils.customFeedPostSortTypeBaseKey + myCustomFeed.path)
            if let time = sortType.time {
                UserDefaults.sortType?.set(time.rawValue, forKey: SortTypeUserDetailsUtils.customFeedPostSortTimeBaseKey + myCustomFeed.path)
            }
        }
    }
}

extension PostListingType {
    var savedPostLayout: PostLayout {
        switch self {
        case .frontPage:
            return PostLayoutUserDefaultsUtils.frontPage
        case .subreddit(let subredditName):
            return PostLayoutUserDefaultsUtils.getSubreddit(subredditName)
        case .user(let username, _):
            return PostLayoutUserDefaultsUtils.getUser(username)
        case .search:
            return PostLayoutUserDefaultsUtils.search
        case .customFeed(let path):
            return PostLayoutUserDefaultsUtils.getCustomFeed(path)
        case .anonymousFrontPage:
            return PostLayoutUserDefaultsUtils.getSubreddit(Account.ANONYMOUS_ACCOUNT.username)
        case .anonymousCustomFeed(let myCustomFeed, _):
            return PostLayoutUserDefaultsUtils.getCustomFeed(myCustomFeed.path)
        }
    }
    
    func savePostLayout(postLayout: PostLayout) {
        switch self {
        case .frontPage:
            PostLayoutUserDefaultsUtils.saveFrontPage(postLayout)
        case .subreddit(let subredditName):
            PostLayoutUserDefaultsUtils.saveSubreddit(subredditName, postLayout)
        case .user(let username, _):
            PostLayoutUserDefaultsUtils.saveUser(username, postLayout)
        case .search:
            PostLayoutUserDefaultsUtils.saveSearch(postLayout)
        case .customFeed(let path):
            PostLayoutUserDefaultsUtils.saveCustomFeed(path, postLayout)
        case .anonymousFrontPage:
            PostLayoutUserDefaultsUtils.saveSubreddit(Account.ANONYMOUS_ACCOUNT.username, postLayout)
        case .anonymousCustomFeed(let myCustomFeed, _):
            PostLayoutUserDefaultsUtils.saveCustomFeed(myCustomFeed.path, postLayout)
        }
    }
}

extension PostListingType {
    var hideReadPostsAutomatically: Bool {
        switch self {
        case .subreddit(let subredditName):
            if subredditName == "popular" || subredditName == "all" {
                return PostHistoryUserDefaultsUtils.hideReadPostsAutomatically
            }
            return PostHistoryUserDefaultsUtils.hideReadPostsAutomatically && PostHistoryUserDefaultsUtils.hideReadPostsAutomaticallyInSubreddits
        case .user:
            return PostHistoryUserDefaultsUtils.hideReadPostsAutomatically && PostHistoryUserDefaultsUtils.hideReadPostsAutomaticallyInUsers
        case .search:
            return PostHistoryUserDefaultsUtils.hideReadPostsAutomatically && PostHistoryUserDefaultsUtils.hideReadPostsAutomaticallyInSearch
        default:
            return PostHistoryUserDefaultsUtils.hideReadPostsAutomatically
        }
    }
}
