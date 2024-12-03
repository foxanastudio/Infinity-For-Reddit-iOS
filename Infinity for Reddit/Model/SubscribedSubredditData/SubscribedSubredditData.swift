//
//  SubscribedSubredditData.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-02.
//

import GRDB

struct SubscribedSubredditData: Codable, FetchableRecord, PersistableRecord {
    static let ANONYMOUS_ACCOUNT = "-"
    static let databaseTableName = "subscribed_subreddits"
    
    var id: String
    var name: String?
    var iconUrl: String?
    var username: String
    var favorite: Bool

    init(id: String, name: String? = nil, iconUrl: String? = nil, username: String, favorite: Bool) {
        self.id = id
        self.name = name
        self.iconUrl = iconUrl
        self.username = username
        self.favorite = favorite
    }
}
