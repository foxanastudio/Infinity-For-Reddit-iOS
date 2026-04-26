//
//  SubredditData.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-01.
//

import GRDB

public struct SubredditData: Codable, FetchableRecord, PersistableRecord, Identifiable, Equatable, Hashable {
    public static let databaseTableName = "subreddits"
    
    public var id: String
    var fullName: String
    var name: String
    var iconUrl: String?
    var bannerUrl: String?
    var description: String?
    var sidebarDescription: String?
    var nSubscribers: Int
    var createdUTC: Int64
    var suggestedCommentSort: String?
    var isSensitive: Bool
    var isSubscribed: Bool = false
    
    var syncTimeInSecond: Int
    
    init(id: String, name: String, fullName: String, iconUrl: String? = nil, bannerUrl: String? = nil,
         description: String? = nil, sidebarDescription: String? = nil, nSubscribers: Int, createdUTC: Int64,
         suggestedCommentSort: String? = nil, isSensitive: Bool, syncTimeInSecond: Int) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.iconUrl = iconUrl
        self.bannerUrl = bannerUrl
        self.description = description
        self.sidebarDescription = sidebarDescription
        self.nSubscribers = nSubscribers
        self.createdUTC = createdUTC
        self.suggestedCommentSort = suggestedCommentSort
        self.isSensitive = isSensitive
        self.syncTimeInSecond = syncTimeInSecond
    }
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case name
        case fullName = "full_name"
        case iconUrl = "icon_url"
        case bannerUrl = "banner_url"
        case description = "description"
        case sidebarDescription = "sidebar_description"
        case nSubscribers = "n_subscribers"
        case createdUTC = "created_utc"
        case suggestedCommentSort = "suggested_comment_sort"
        case isSensitive = "is_sensitive"
        case syncTimeInSecond = "sync_time_in_second"
    }
    
    public static let databaseSelection: [SQLSelectable] = CodingKeys.allCases.map { $0 }
    
    func toSubscribedSubredditData() -> SubscribedSubredditData {
        return SubscribedSubredditData(
            fullName: fullName,
            name: name,
            iconUrl: iconUrl,
            username: AccountViewModel.shared.account.username,
            isFavorite: false
        )
    }
}
