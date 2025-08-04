//
//  PostListingType.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-29.
//

extension PostListingType: SortTypeKindSource {
    var availableSortTypeKinds: [SortType.Kind] {
        switch self {
        case .frontPage:
            return [.best, .hot, .new, .rising, .top, .controversial]
        case .subreddit:
            return [.hot, .new, .rising, .top, .controversial]
        case .user(username: let username, userWhere: let userWhere):
            return [.new, .hot, .top, .controversial]
        case .search(query: let query, searchInSubredditOrUserName: let searchInSubredditOrUserName, searchInMultiReddit: let searchInMultiReddit, searchInThingType: let searchInThingType):
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
