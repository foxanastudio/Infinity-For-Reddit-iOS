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
    
    
//    func isPostAllowed(post: Post?, postFilter: PostFilter?) -> Bool {
//        guard let post = post, let postFilter = postFilter else {
//            return true
//        }
//        
//        if post.isNSFW() && !postFilter.allowNSFW {
//            return false
//        }
//        if postFilter.maxVote > 0 && post.voteType + post.score > postFilter.maxVote {
//            return false
//        }
//        if postFilter.minVote > 0 && post.voteType + post.score < postFilter.minVote {
//            return false
//        }
//        if postFilter.maxComments > 0 && post.nComments > postFilter.maxComments {
//            return false
//        }
//        if postFilter.minComments > 0 && post.nComments < postFilter.minComments {
//            return false
//        }
//        if postFilter.onlyNSFW && !post.isNSFW {
//            return postFilter.onlySpoiler ? post.isSpoiler : false
//        }
//        if postFilter.onlySpoiler && !post.isSpoiler {
//            return postFilter.onlyNSFW ? post.isNSFW : false
//        }
//        if !postFilter.containTextType && post.postType == .text {
//            return false
//        }
//        if !postFilter.containLinkType && (post.postType == .link || post.postType == .noPreviewLink) {
//            return false
//        }
//        if !postFilter.containImageType && post.postType == .image {
//            return false
//        }
//        if !postFilter.containGifType && post.postType == .gif {
//            return false
//        }
//        if !postFilter.containVideoType && post.postType == .video {
//            return false
//        }
//        if !postFilter.containGalleryType && post.postType == .gallery {
//            return false
//        }
//        if let excludesRegex = postFilter.postTitleExcludesRegex, !excludesRegex.isEmpty {
//            if let regex = try? NSRegularExpression(pattern: excludesRegex) {
//                if regex.firstMatch(in: post.title, options: [], range: NSRange(location: 0, length: post.title.utf16.count)) != nil {
//                    return false
//                }
//            }
//        }
//        if let containsRegex = postFilter.postTitleContainsRegex, !containsRegex.isEmpty {
//            if let regex = try? NSRegularExpression(pattern: containsRegex) {
//                if regex.firstMatch(in: post.title, options: [], range: NSRange(location: 0, length: post.title.utf16.count)) == nil {
//                    return false
//                }
//            }
//        }
//        if let excludesStrings = postFilter.postTitleExcludesStrings, !excludesStrings.isEmpty {
//            let titles = excludesStrings.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//            if titles.contains(where: { post.title.localizedCaseInsensitiveContains($0) }) {
//                return false
//            }
//        }
//        if let containsStrings = postFilter.postTitleContainsStrings, !containsStrings.isEmpty {
//            let titles = containsStrings.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//            if !titles.contains(where: { post.title.localizedCaseInsensitiveContains($0) }) {
//                return false
//            }
//        }
//        if let excludeSubreddits = postFilter.excludeSubreddits, !excludeSubreddits.isEmpty {
//            let subreddits = excludeSubreddits.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//            if subreddits.contains(where: { $0.localizedCaseInsensitiveCompare(post.subredditName) == .orderedSame }) {
//                return false
//            }
//        }
//        if let excludeUsers = postFilter.excludeUsers, !excludeUsers.isEmpty {
//            let users = excludeUsers.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//            if users.contains(where: { $0.localizedCaseInsensitiveCompare(post.author) == .orderedSame }) {
//                return false
//            }
//        }
//        if let excludeFlairs = postFilter.excludeFlairs, !excludeFlairs.isEmpty {
//            let flairs = excludeFlairs.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//            if flairs.contains(where: { $0.localizedCaseInsensitiveCompare(post.flair) == .orderedSame }) {
//                return false
//            }
//        }
//        if let url = post.url, let excludeDomains = postFilter.excludeDomains, !excludeDomains.isEmpty {
//            let domains = excludeDomains.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
//            if domains.contains(where: { url.lowercased().contains($0) }) {
//                return false
//            }
//        }
//        if let url = post.url, let containDomains = postFilter.containDomains, !containDomains.isEmpty {
//            let domains = containDomains.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
//            if !domains.contains(where: { url.lowercased().contains($0) }) {
//                return false
//            }
//        }
//        if let containFlairs = postFilter.containFlairs, !containFlairs.isEmpty {
//            let flairs = containFlairs.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//            if flairs.isEmpty || !flairs.contains(where: { $0.localizedCaseInsensitiveCompare(post.flair) == .orderedSame }) {
//                return false
//            }
//        }
//        
//        return true
//    }
}
