//
//  UserData.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-03-05.
//  

import GRDB

public struct UserData: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "users"
    
    var id: String
    var name: String
    var iconUrl: String?
    var banner: String?
    var commentKarma: Int?
    var linkKarma: Int?
    var awarderKarma: Int?
    var awardeeKarma: Int?
    var totalKarma: Int?
    var cakeday: Double?
    var isGold: Bool?
    var isSubscribed: Bool?
    var canBeFollowed: Bool?
    var isNSFW: Bool?
    var description: String?
    var title: String?
    var isSelected: Bool
    
    init(id: String, name: String, iconUrl: String? = nil, banner: String? = nil, commentKarma: Int? = nil, linkKarma: Int? = nil, awarderKarma: Int? = nil, awardeeKarma: Int? = nil, totalKarma: Int? = nil, cakeday: Double? = nil, isGold: Bool? = nil, isSubscribed: Bool? = nil, canBeFollowed: Bool? = nil, isNSFW: Bool? = nil, description: String? = nil, title: String? = nil) {
        self.id = id
        self.name = name
        self.iconUrl = iconUrl
        self.banner = banner
        self.commentKarma = commentKarma
        self.linkKarma = linkKarma
        self.awarderKarma = awarderKarma
        self.awardeeKarma = awardeeKarma
        self.totalKarma = totalKarma
        self.cakeday = cakeday
        self.isGold = isGold
        self.isSubscribed = isSubscribed
        self.canBeFollowed = canBeFollowed
        self.isNSFW = isNSFW
        self.description = description
        self.title = title
        self.isSelected = false
    }
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case name
        case iconUrl = "icon_url"
        case banner = "banner_url"
        case commentKarma = "comment_karma"
        case linkKarma = "link_karma"
        case awarderKarma = "awarder_karma"
        case awardeeKarma = "awardee_karma"
        case totalKarma = "total_karma"
        case cakeday = "cakeday"
        case isGold = "is_gold"
        case isSubscribed = "is_subscribed"
        case canBeFollowed = "can_follow"
        case isNSFW = "is_nsfw"
        case description = "description"
        case title = "title"
        case isSelected = "is_selected"
    }
}
