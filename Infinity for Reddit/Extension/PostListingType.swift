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
        case .multireddit:
            return [.hot, .new, .rising, .top, .controversial]
        case .anonymousFrontPage:
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
        if case .user = self {
            return .inQuery(key: "sort")
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
            return .home
        case .subreddit:
            return .subreddit
        case .user:
            return .user
        case .search:
            return .search
        case .multireddit:
            return .customFeed
        case .anonymousFrontPage:
            return .home
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
        case .multireddit(let path):
            return path
        case .anonymousFrontPage:
            return PostFilterUsage.NO_USAGE
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
        case .multireddit(let path):
            return SortTypeUserDetailsUtils.getCustomFeedPost(path: path)
        case .anonymousFrontPage:
            return SortTypeUserDetailsUtils.getSubredditPost(subredditName: Account.ANONYMOUS_ACCOUNT.username)
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
        case .multireddit(let path):
            UserDefaults.sortType?.set(sortType.type.rawValue, forKey: SortTypeUserDetailsUtils.customFeedPostSortTypeBaseKey + path)
            if let time = sortType.time {
                UserDefaults.sortType?.set(time.rawValue, forKey: SortTypeUserDetailsUtils.customFeedPostSortTimeBaseKey + path)
            }
        case .anonymousFrontPage:
            UserDefaults.sortType?.set(sortType.type.rawValue, forKey: SortTypeUserDetailsUtils.subredditPostSortTypeBaseKey + Account.ANONYMOUS_ACCOUNT.username)
            if let time = sortType.time {
                UserDefaults.sortType?.set(time.rawValue, forKey: SortTypeUserDetailsUtils.subredditPostSortTimeBaseKey + Account.ANONYMOUS_ACCOUNT.username)
            }
        }
    }
}
