//
//  Account.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-01.
//

import GRDB

struct Account: Codable, FetchableRecord, PersistableRecord {
    static let ANONYMOUS_ACCOUNT = "-"
    static let databaseTableName = "accounts"
    
    var username: String
    var isCurrentUser: Bool
    var profileImageUrl: String?
    var bannerImageUrl: String?
    var karma: Int
    var accessToken: String?
    var refreshToken: String?
    
    init(username: String, isCurrentUser: Bool, profileImageUrl: String? = nil, bannerImageUrl: String? = nil, karma: Int, accessToken: String? = nil, refreshToken: String? = nil) {
        self.username = username
        self.isCurrentUser = isCurrentUser
        self.profileImageUrl = profileImageUrl
        self.bannerImageUrl = bannerImageUrl
        self.karma = karma
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
