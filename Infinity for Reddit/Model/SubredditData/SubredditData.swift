//
//  SubredditData.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-01.
//

import GRDB

struct SubredditData: Codable, FetchableRecord, PersistableRecord {
    static let ANONYMOUS_ACCOUNT = "-"
    static let databaseTableName = "subreddits"
    
    let id: String
    let name: String?
    let iconUrl: String?
    let bannerUrl: String?
    let description: String?
    let sidebarDescription: String?
    let nSubscribers: Int
    let createdUTC: Int  
    let suggestedCommentSort: String?
    let isNSFW: Bool
    var isSelected: Bool = false
}
