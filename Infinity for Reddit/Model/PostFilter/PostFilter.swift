//
// PostFilter.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB

struct PostFilter: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "post_filter"
    
    // Primary key
    var name: String = "New Filter"

    // Vote filters
    var maxVote: Int = -1
    var minVote: Int = -1

    // Comment filters
    var maxComments: Int = -1
    var minComments: Int = -1

    // Award filters
    var maxAwards: Int = -1
    var minAwards: Int = -1

    // NSFW and Spoiler filters
    var allowNSFW: Bool = false
    var onlyNSFW: Bool = false
    var onlySpoiler: Bool = false

    // Title filters
    var postTitleExcludesRegex: String?
    var postTitleContainsRegex: String?
    var postTitleExcludesStrings: String?
    var postTitleContainsStrings: String?

    // Subreddit, User, Flair filters
    var excludeSubreddits: String?
    var excludeUsers: String?
    var containFlairs: String?
    var excludeFlairs: String?

    // Domain filters
    var excludeDomains: String?
    var containDomains: String?

    // Content type filters
    var containTextType: Bool = true
    var containLinkType: Bool = true
    var containImageType: Bool = true
    var containGifType: Bool = true
    var containVideoType: Bool = true
    var containGalleryType: Bool = true
    
    init() { } 
}
