//
//  Account.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-01.
//

import GRDB
import Foundation

public struct Account: Codable, FetchableRecord, PersistableRecord, Sendable, Equatable {
    static let ANONYMOUS_ACCOUNT = Account(username: "-", isCurrentUser: false, profileImageUrl: nil, bannerImageUrl: nil, karma: 0, isMod: false, accessToken: nil, refreshToken: nil, code: nil, createdUTC: 0.0)
    
    public static let databaseTableName = "accounts"
    
    var username: String
    var isCurrentUser: Bool
    var profileImageUrl: String?
    var bannerImageUrl: String?
    var karma: Int
    var isMod: Bool
    var accessToken: String?
    var refreshToken: String?
    var code: String?
    var subscriptionSyncTime: Int64
    var createdUTC: TimeInterval
    
    init(username: String, isCurrentUser: Bool, profileImageUrl: String? = nil, bannerImageUrl: String? = nil, karma: Int, isMod: Bool, accessToken: String? = nil, refreshToken: String? = nil, code: String? = nil, createdUTC: TimeInterval) {
        self.username = username
        self.isCurrentUser = isCurrentUser
        self.profileImageUrl = profileImageUrl
        self.bannerImageUrl = bannerImageUrl
        self.karma = karma
        self.isMod = isMod
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.code = code
        self.subscriptionSyncTime = 0
        self.createdUTC = createdUTC
    }
    
    func isAnonymous() -> Bool {
        username == "-"
    }
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case username
        case isCurrentUser = "is_current_user"
        case profileImageUrl = "profile_image_url"
        case bannerImageUrl = "banner_image_url"
        case karma
        case isMod = "is_mod"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case code
        case subscriptionSyncTime = "subscription_sync_time"
        case createdUTC = "created_utc"
    }
    
    public static let databaseSelection: [SQLSelectable] = CodingKeys.allCases.map { $0 }
}
