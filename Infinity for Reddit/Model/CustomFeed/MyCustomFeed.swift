//
// MyCustomFeed.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-03
//

import GRDB
import Foundation

public class MyCustomFeed: Codable, FetchableRecord, PersistableRecord, Equatable, Hashable, Identifiable {
    public static let databaseTableName = "custom_feeds"
    
    public var id: String {
        return path
    }
    
    var path: String
    var displayName: String
    var name: String
    var description: String?
    var copiedFrom: String?
    var iconUrl: String?
    var visibility: String?
    var owner: String
    var nSubscribers: Int
    var createdUTC: Int64
    var over18: Bool
    var isSubscriber: Bool
    var isFavorite: Bool
    var subreddits: [String]?
    
    init(path: String, displayName: String, name: String, description: String? = nil,
         copiedFrom: String? = nil, iconUrl: String? = nil, visibility: String? = nil,
         owner: String, nSubscribers: Int, createdUTC: Int64, over18: Bool,
         isSubscriber: Bool, isFavorite: Bool, subreddits: [String]? = nil) {
        self.path = path
        self.displayName = displayName
        self.name = name
        self.description = description
        self.copiedFrom = copiedFrom
        self.iconUrl = iconUrl
        self.visibility = visibility
        self.owner = owner
        self.nSubscribers = nSubscribers
        self.createdUTC = createdUTC
        self.over18 = over18
        self.isSubscriber = isSubscriber
        self.isFavorite = isFavorite
        self.subreddits = subreddits
    }
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case path
        case displayName = "display_name"
        case name
        case description
        case copiedFrom = "copied_from"
        case iconUrl = "icon_url"
        case visibility
        case owner = "username"
        case nSubscribers = "n_subscribers"
        case createdUTC = "created_utc"
        case over18
        case isSubscriber = "is_subscriber"
        case isFavorite = "is_favorite"
    }

    public static let databaseSelection: [SQLSelectable] = CodingKeys.allCases.map { $0 }
    
    // Equatable conformance
    public static func == (lhs: MyCustomFeed, rhs: MyCustomFeed) -> Bool {
        return lhs.path == rhs.path && lhs.owner == rhs.owner
    }
    
    // Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(owner)
    }
}
