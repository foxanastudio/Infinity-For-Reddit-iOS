//
// SubscribedUserData.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-03
//

import GRDB
import Foundation

class SubscribedUserData: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName: String = "subscribed_users"
    
    var id: String {
        return name
    }
    
    var name: String
    var iconUrl: String?
    var username: String
    var isFavorite: Bool
    
    init(name: String, iconUrl: String?, username: String, isFavorite: Bool) {
        self.name = name
        self.iconUrl = iconUrl
        self.username = username
        self.isFavorite = isFavorite
    }
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case name
        case iconUrl = "icon_url"
        case username
        case isFavorite = "is_favorite"
    }
    
    public static let databaseSelection: [SQLSelectable] = CodingKeys.allCases.map { $0 }
}

extension SubscribedUserData {
    static func fromUser(_ u: User, username: String) -> SubscribedUserData {
        return SubscribedUserData(
            name: u.name ?? "",
            iconUrl: u.iconUrl,
            username: username,
            isFavorite: false
        )
    }
}
