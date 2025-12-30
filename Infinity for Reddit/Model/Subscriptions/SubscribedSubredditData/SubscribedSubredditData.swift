//
//  SubscribedSubredditData.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-02.
//

import GRDB
import Foundation

class SubscribedSubredditData: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "subscribed_subreddits"
    
    var id: String {
        return String(fullName.dropFirst(3))
    }
    
    var fullName: String
    var name: String
    var iconUrl: String?
    var username: String
    var isFavorite: Bool

    init(fullName: String = "", name: String, iconUrl: String? = nil, username: String, isFavorite: Bool = false) {
        self.fullName = fullName
        self.name = name
        self.iconUrl = iconUrl
        self.username = username
        self.isFavorite = isFavorite
    }
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case fullName = "full_name"
        case name
        case iconUrl = "icon_url"
        case username
        case isFavorite = "is_favorite"
    }
    
    public static let databaseSelection: [SQLSelectable] = CodingKeys.allCases.map { $0 }
}

extension SubscribedSubredditData {
    static func fromSubreddit(_ s: Subreddit, username: String) -> SubscribedSubredditData {
        return SubscribedSubredditData(
            fullName: s.name ?? "",    
            name: s.displayName ?? "",
            iconUrl: s.iconImg ?? s.communityIcon,
            username: username,
            isFavorite: false
        )
    }
}
