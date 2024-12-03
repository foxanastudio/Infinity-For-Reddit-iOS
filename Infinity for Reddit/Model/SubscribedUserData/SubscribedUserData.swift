//
// SubscribedUserData.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-03
//

import GRDB

struct SubscribedUserData: Codable, FetchableRecord, PersistableRecord {
    static let ANONYMOUS_ACCOUNT = "-"
    static let databaseTableName: String = "subscribed_users"
    
    var name: String
    var iconUrl: String?
    var username: String
    var favorite: Bool
    
    init(name: String, iconUrl: String?, username: String, favorite: Bool){
        self.name = name
        self.iconUrl = iconUrl
        self.username = username
        self.favorite = favorite
    }
    
}
