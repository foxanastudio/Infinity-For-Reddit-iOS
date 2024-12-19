//
//  SubredditData.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-01.
//

import GRDB

struct SubredditData: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "subreddits"
    
    var id: String
    var name: String?
    var iconUrl: String?
    var bannerUrl: String?
    var description: String?
    var sidebarDescription: String?
    var nSubscribers: Int
    var createdUTC: Int64
    var suggestedCommentSort: String?
    var isNSFW: Bool
    var isSelected: Bool = false
    
    init(id: String, name: String? = nil, iconUrl: String? = nil, bannerUrl: String? = nil,
         description: String? = nil, sidebarDescription: String? = nil, nSubscribers: Int, createdUTC: Int64,
         suggestedCommentSort: String? = nil, isNSFW: Bool) {
        self.id = id
        self.name = name
        self.iconUrl = iconUrl
        self.bannerUrl = bannerUrl
        self.description = description
        self.sidebarDescription = sidebarDescription
        self.nSubscribers = nSubscribers
        self.createdUTC = createdUTC
        self.suggestedCommentSort = suggestedCommentSort
        self.isNSFW = isNSFW
        self.isSelected = false
    }
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case name
        case iconUrl = "icon_url"
        case bannerUrl = "banner_url"
        case description
        case sidebarDescription = "sidebar_description"
        case nSubscribers = "n_subscribers"
        case createdUTC = "created_utc"
        case suggestedCommentSort = "suggested_comment_sort"
        case isNSFW = "is_nsfw"
    }
    
    public static let databaseSelection: [SQLSelectable] = CodingKeys.allCases.map { $0 }
}
