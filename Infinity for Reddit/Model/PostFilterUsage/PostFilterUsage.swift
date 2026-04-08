//
// PostFilterUsage.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB

public struct PostFilterUsage: Codable, FetchableRecord, PersistableRecord, Hashable {
    public static let databaseTableName = "post_filter_usage"
    static let HISTORY_TYPE_USAGE_READ_POSTS = "-read-posts"
    static let HISTORY_TYPE_USAGE_UPVOTED_POSTS = "-upvoted-posts"
    static let HISTORY_TYPE_USAGE_DOWNVOTED_POSTS = "-downvoted-posts"
    static let HISTORY_TYPE_USAGE_HIDDEN_POSTS = "-hidden-posts"
    static let HISTORY_TYPE_USAGE_SAVED_POSTS = "-saved-posts"
    static let NO_USAGE = "--"
    
    enum UsageType: Int, Codable {
        case frontPage = 1
        case subreddit = 2
        case user = 3
        case customFeed = 4
        case search = 5
        case history = 6
        
        var description: String {
            switch self {
            case .frontPage:
                return "Front Page"
            case .subreddit:
                return "Subreddit"
            case .user:
                return "User"
            case .customFeed:
                return "Custom Feed"
            case .search:
                return "Search"
            case .history:
                return "History"
            }
        }
        
        var textFieldPlaceholder: String {
            switch self {
            case .subreddit:
                return "Subreddit Name (Without r/ prefix)"
            case .user:
                return "Username (Without u/ prefix)"
            case .customFeed:
                return "Path (/user/yourusername/m/yourmultiredditname) (only lowercase characters)"
            default:
                // Really shouldn't happen
                return ""
            }
        }
    }

    var postFilterId: Int
    var usageType: UsageType
    var nameOfUsage: String
    
    var description: String {
        switch self.usageType {
        case .frontPage:
            return UsageType.frontPage.description
        case .subreddit:
            if nameOfUsage == PostFilterUsage.NO_USAGE {
                return "All subreddits"
            }
            return "r/" + nameOfUsage
        case .user:
            if nameOfUsage == PostFilterUsage.NO_USAGE {
                return "All users"
            }
            return "u/" + nameOfUsage
        case .customFeed:
            if nameOfUsage == PostFilterUsage.NO_USAGE {
                return "All custom feeds"
            }
            return "Custom Feed: " + nameOfUsage
        case .search:
            return "Search"
        case .history:
            if nameOfUsage == PostFilterUsage.HISTORY_TYPE_USAGE_READ_POSTS {
                return "Read posts"
            }
            return UsageType.history.description
        }
    }

    init(postFilterId: Int, usageType: UsageType, nameOfUsage: String? = nil) {
        self.postFilterId = postFilterId
        self.usageType = usageType
        self.nameOfUsage = nameOfUsage ?? PostFilterUsage.NO_USAGE
    }

    private enum CodingKeys: String, CodingKey, ColumnExpression {
        case postFilterId = "post_filter_id", usageType = "usage_type", nameOfUsage = "name_of_usage"
    }
}
