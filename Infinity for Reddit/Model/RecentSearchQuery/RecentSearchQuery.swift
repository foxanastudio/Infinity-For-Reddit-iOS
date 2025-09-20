//
// RecentSearchQuery.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-03
//

import GRDB

public struct RecentSearchQuery: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "recent_search_queries"
    
    var username: String
    var searchQuery: String
    var searchInSubredditOrUserName: String?
    var customFeedPath: String?
    var customFeedDisplayName: String?
    var searchInThingType: SearchInThingType
    var time: Int64
    
    init(username: String, searchQuery: String, searchInSubredditOrUserName: String? = nil, customFeedPath: String? = nil,
         customFeedDisplayName: String? = nil, searchInThingType: SearchInThingType, time: Int64) {
        self.username = username
        self.searchQuery = searchQuery
        self.searchInSubredditOrUserName = searchInSubredditOrUserName
        self.customFeedPath = customFeedPath
        self.customFeedDisplayName = customFeedDisplayName
        self.searchInThingType = searchInThingType
        self.time = time
    }
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case username
        case searchQuery = "search_query"
        case searchInSubredditOrUserName = "search_in_subreddit_or_user_name"
        case customFeedPath = "search_in_multireddit_path"
        case customFeedDisplayName = "search_in_multireddit_display_name"
        case searchInThingType = "search_in_thing_type"
        case time
    }
    
    public static let databaseSelection: [SQLSelectable] = CodingKeys.allCases.map { $0 }
}
