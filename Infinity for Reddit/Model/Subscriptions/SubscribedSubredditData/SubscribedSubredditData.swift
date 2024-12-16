//
//  SubscribedSubredditData.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-02.
//

import GRDB

struct SubscribedSubredditData: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "subscribed_subreddits"
    
    var fullName: String
    var name: String?
    var iconUrl: String?
    var username: String
    var favorite: Bool

    init(fullName: String, name: String? = nil, iconUrl: String? = nil, username: String, favorite: Bool) {
        self.fullName = fullName
        self.name = name
        self.iconUrl = iconUrl
        self.username = username
        self.favorite = favorite
    }
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case fullName = "full_name"
        case name
        case iconUrl = "icon_url"
        case username
        case favorite
    }
    
    public static let databaseSelection: [SQLSelectable] = CodingKeys.allCases.map { $0 }
}
