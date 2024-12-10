//
// PostFilter.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB

struct PostFilter: Codable, FetchableRecord, PersistableRecord, Equatable {
    static let databaseTableName = "post_filter"
    
    // Primary key
    var id: Int?
    
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
    
    init(
            id: Int? = nil,
            name: String = "New Filterdamn",
            maxVote: Int = -1,
            minVote: Int = -1,
            maxComments: Int = -1,
            minComments: Int = -1,
            maxAwards: Int = -1,
            minAwards: Int = -1,
            allowNSFW: Bool = false,
            onlyNSFW: Bool = false,
            onlySpoiler: Bool = false,
            postTitleExcludesRegex: String? = nil,
            postTitleContainsRegex: String? = nil,
            postTitleExcludesStrings: String? = nil,
            postTitleContainsStrings: String? = nil,
            excludeSubreddits: String? = nil,
            excludeUsers: String? = nil,
            containFlairs: String? = nil,
            excludeFlairs: String? = nil,
            excludeDomains: String? = nil,
            containDomains: String? = nil,
            containTextType: Bool = true,
            containLinkType: Bool = true,
            containImageType: Bool = true,
            containGifType: Bool = true,
            containVideoType: Bool = true,
            containGalleryType: Bool = true
        ) {
            self.id = id
            self.name = name
            self.maxVote = maxVote
            self.minVote = minVote
            self.maxComments = maxComments
            self.minComments = minComments
            self.maxAwards = maxAwards
            self.minAwards = minAwards
            self.allowNSFW = allowNSFW
            self.onlyNSFW = onlyNSFW
            self.onlySpoiler = onlySpoiler
            self.postTitleExcludesRegex = postTitleExcludesRegex
            self.postTitleContainsRegex = postTitleContainsRegex
            self.postTitleExcludesStrings = postTitleExcludesStrings
            self.postTitleContainsStrings = postTitleContainsStrings
            self.excludeSubreddits = excludeSubreddits
            self.excludeUsers = excludeUsers
            self.containFlairs = containFlairs
            self.excludeFlairs = excludeFlairs
            self.excludeDomains = excludeDomains
            self.containDomains = containDomains
            self.containTextType = containTextType
            self.containLinkType = containLinkType
            self.containImageType = containImageType
            self.containGifType = containGifType
            self.containVideoType = containVideoType
            self.containGalleryType = containGalleryType
        }
}
