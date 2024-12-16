//
// MultiReddit.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-03
//

import GRDB

struct MultiReddit: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "multi_reddits"
    
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
}
