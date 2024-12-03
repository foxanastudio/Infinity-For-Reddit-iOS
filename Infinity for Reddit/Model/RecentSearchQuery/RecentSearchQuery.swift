//
// RecentSearchQuery.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-03
//

import GRDB

struct RecentSearchQuery: Codable, FetchableRecord, PersistableRecord {
    static let ANONYMOUS_ACCOUNT = "-"
    static let databaseTableName: String = "recent_search_queries"
    
    var username: String
    var searchQuery: String
    var searchInSubredditOrUserName: String?
    var multiRedditPath: String?
    var multiRedditDisplayName: String?
    var searchInThingType: Int  
    var time: Int64
    
    init(username: String, searchQuery: String, searchInSubredditOrUserName: String? = nil, multiRedditPath: String? = nil,
         multiRedditDisplayName: String? = nil, searchInThingType: Int, time: Int64) {
        self.username = username
        self.searchQuery = searchQuery
        self.searchInSubredditOrUserName = searchInSubredditOrUserName
        self.multiRedditPath = multiRedditPath
        self.multiRedditDisplayName = multiRedditDisplayName
        self.searchInThingType = searchInThingType
        self.time = time
        
    }
}
