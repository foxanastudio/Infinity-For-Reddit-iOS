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
    static let NO_USAGE = "--"
    
    enum UsageType: Int, Codable {
        case home = 1
        case subreddit = 2
        case user = 3
        case customFeed = 4
        case search = 5
        case history = 6
    }

    var postFilterId: Int
    var usageType: UsageType
    var nameOfUsage: String
    
    var description: String {
        switch self.usageType {
        case .home:
            return "Home"
        case .subreddit:
            if nameOfUsage == PostFilterUsage.NO_USAGE {
                return "Subreddit"
            }
            return "r/" + nameOfUsage
        case .user:
            if nameOfUsage == PostFilterUsage.NO_USAGE {
                return "User"
            }
            return "u/" + nameOfUsage
        case .customFeed:
            if nameOfUsage == PostFilterUsage.NO_USAGE {
                return "Custom Feed"
            }
            return "Custom Feed:" + nameOfUsage
        case .search:
            return "Search"
        case .history:
            if nameOfUsage == PostFilterUsage.HISTORY_TYPE_USAGE_READ_POSTS {
                return "Read posts"
            }
            return "History"
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
