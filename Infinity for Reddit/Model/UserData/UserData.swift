//
//  UserData.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-02.
//

import GRDB

struct UserData: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName: String = "users"
    
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
    var isFriend: Bool?
    var canBeFollowed: Bool?
    var isNSFW: Bool?
    var description: String?
    var title: String?
    var isSelected: Bool
    
    init(name: String, iconUrl: String? = nil, banner: String? = nil, commentKarma: Int? = nil, linkKarma: Int? = nil, awarderKarma: Int? = nil, awardeeKarma: Int? = nil, totalKarma: Int? = nil, cakeday: Double? = nil, isGold: Bool? = nil, isFriend: Bool? = nil, canBeFollowed: Bool? = nil, isNSFW: Bool? = nil, description: String? = nil, title: String? = nil) {
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
        self.isFriend = isFriend
        self.canBeFollowed = canBeFollowed
        self.isNSFW = isNSFW
        self.description = description
        self.title = title
        self.isSelected = false
    }
}
