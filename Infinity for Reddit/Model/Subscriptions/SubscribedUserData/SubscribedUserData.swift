//
// SubscribedUserData.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-03
//

import GRDB
import Foundation

class SubscribedUserData: Codable, FetchableRecord, PersistableRecord {
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
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case name
        case iconUrl = "icon_url"
        case username
        case favorite
    }
    
    public static let databaseSelection: [SQLSelectable] = CodingKeys.allCases.map { $0 }
}
