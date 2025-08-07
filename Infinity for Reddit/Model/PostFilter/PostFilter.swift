//
// PostFilter.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB
import Foundation

public struct PostFilter: Codable, FetchableRecord, PersistableRecord, Equatable, Hashable {
    public static let databaseTableName = "post_filter"
    
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
    
    // Sensitive and spoiler filters
    var onlySensitive: Bool = false
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
    
    // The following fields will not be saved to the database
    var allowSensitive: Bool = false
    var allowSpoiler: Bool = true
    
    var identityForView: String {
        "\(String(id ?? -1))-\(name)"
    }
    
    init(
        id: Int? = nil,
        name: String = "New Filter",
        maxVote: Int = -1,
        minVote: Int = -1,
        maxComments: Int = -1,
        minComments: Int = -1,
        maxAwards: Int = -1,
        minAwards: Int = -1,
        onlySensitive: Bool = false,
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
        self.onlySensitive = onlySensitive
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
    
    enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case name
        case maxVote = "max_vote"
        case minVote = "min_vote"
        case maxComments = "max_comments"
        case minComments = "min_comments"
        case maxAwards = "max_awards"
        case minAwards = "min_awards"
        case onlySensitive = "only_sensitive"
        case onlySpoiler = "only_spoiler"
        case postTitleExcludesRegex = "post_title_excludes_regex"
        case postTitleContainsRegex = "post_title_contains_regex"
        case postTitleExcludesStrings = "post_title_excludes_strings"
        case postTitleContainsStrings = "post_title_contains_strings"
        case excludeSubreddits = "exclude_subreddits"
        case excludeUsers = "exclude_users"
        case containFlairs = "contain_flairs"
        case excludeFlairs = "exclude_flairs"
        case excludeDomains = "exclude_domains"
        case containDomains = "contain_domains"
        case containTextType = "contain_text_type"
        case containLinkType = "contain_link_type"
        case containImageType = "contain_image_type"
        case containGifType = "contain_gif_type"
        case containVideoType = "contain_video_type"
        case containGalleryType = "contain_gallery_type"
    }
    
    static func isPostAllowed(post: Post?, postFilter: PostFilter?) -> Bool {
        guard let post = post, let postFilter = postFilter else {
            return true
        }
        
        if post.over18 && !postFilter.allowSensitive {
            return false
        }
        
        if post.spoiler && !postFilter.allowSpoiler {
            return false
        }
        
        if postFilter.maxVote > 0 && post.likes + post.score > postFilter.maxVote {
            return false
        }
        if postFilter.minVote > 0 && post.likes + post.score < postFilter.minVote {
            return false
        }
        if postFilter.maxComments > 0 && post.numComments > postFilter.maxComments {
            return false
        }
        if postFilter.minComments > 0 && post.numComments < postFilter.minComments {
            return false
        }
        if postFilter.onlySensitive && !post.over18 {
            return postFilter.onlySpoiler ? post.spoiler : false
        }
        if postFilter.onlySpoiler && !post.spoiler {
            return postFilter.onlySensitive ? post.over18 : false
        }
        
        switch post.postType {
        case .text:
            if !postFilter.containTextType {
                return false
            }
        case .image:
            if !postFilter.containImageType {
                return false
            }
        case .imageWithUrlPreview:
            if !postFilter.containImageType {
                return false
            }
        case .gif:
            if !postFilter.containGifType {
                return false
            }
        case .video:
            if !postFilter.containVideoType {
                return false
            }
        case .gallery:
            if !postFilter.containGalleryType {
                return false
            }
        case .link:
            if !postFilter.containLinkType {
                return false
            }
        case .noPreviewLink:
            if !postFilter.containLinkType {
                return false
            }
        case .poll:
            break
        case .imgurVideo:
            if !postFilter.containVideoType {
                return false
            }
        case .redgifs:
            if !postFilter.containVideoType {
                return false
            }
        case .streamable:
            if !postFilter.containVideoType {
                return false
            }
        default:
            break
        }
        
        if let excludesRegex = postFilter.postTitleExcludesRegex, !excludesRegex.isEmpty {
            if let regex = try? NSRegularExpression(pattern: excludesRegex) {
                if regex.firstMatch(in: post.title, options: [], range: NSRange(location: 0, length: post.title.utf16.count)) != nil {
                    return false
                }
            }
        }
        if let containsRegex = postFilter.postTitleContainsRegex, !containsRegex.isEmpty {
            if let regex = try? NSRegularExpression(pattern: containsRegex) {
                if regex.firstMatch(in: post.title, options: [], range: NSRange(location: 0, length: post.title.utf16.count)) == nil {
                    return false
                }
            }
        }
        if let excludesStrings = postFilter.postTitleExcludesStrings, !excludesStrings.isEmpty {
            let titles = excludesStrings.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if titles.contains(where: { post.title.localizedCaseInsensitiveContains($0) }) {
                return false
            }
        }
        if let containsStrings = postFilter.postTitleContainsStrings, !containsStrings.isEmpty {
            let titles = containsStrings.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if !titles.contains(where: { post.title.localizedCaseInsensitiveContains($0) }) {
                return false
            }
        }
        if let excludeSubreddits = postFilter.excludeSubreddits, !excludeSubreddits.isEmpty {
            let subreddits = excludeSubreddits.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if subreddits.contains(where: { $0.localizedCaseInsensitiveCompare(post.subreddit) == .orderedSame }) {
                return false
            }
        }
        if let excludeUsers = postFilter.excludeUsers, !excludeUsers.isEmpty {
            let users = excludeUsers.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if users.contains(where: { $0.localizedCaseInsensitiveCompare(post.author) == .orderedSame }) {
                return false
            }
        }
        if let excludeFlairs = postFilter.excludeFlairs, !excludeFlairs.isEmpty {
            let flairs = excludeFlairs.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if flairs.contains(where: { $0.localizedCaseInsensitiveCompare(post.linkFlairText) == .orderedSame }) {
                return false
            }
        }
        if let url = post.url, let excludeDomains = postFilter.excludeDomains, !excludeDomains.isEmpty {
            let domains = excludeDomains.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            if domains.contains(where: { url.lowercased().contains($0) }) {
                return false
            }
        }
        if let url = post.url, let containDomains = postFilter.containDomains, !containDomains.isEmpty {
            let domains = containDomains.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            if !domains.contains(where: { url.lowercased().contains($0) }) {
                return false
            }
        }
        if let containFlairs = postFilter.containFlairs, !containFlairs.isEmpty {
            let flairs = containFlairs.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if flairs.isEmpty || !flairs.contains(where: { $0.localizedCaseInsensitiveCompare(post.linkFlairText) == .orderedSame }) {
                return false
            }
        }
        
        return true
    }
    
    static func mergePostFilter(_ postFilters: [PostFilter]) -> PostFilter {
        guard !postFilters.isEmpty else {
            return PostFilter()
        }
        if postFilters.count == 1 {
            return postFilters.first!
        }

        var merged = PostFilter()
        merged.name = "Merged"

        for p in postFilters {
            merged.maxVote = min(p.maxVote, merged.maxVote)
            merged.minVote = max(p.minVote, merged.minVote)
            merged.maxComments = min(p.maxComments, merged.maxComments)
            merged.minComments = max(p.minComments, merged.minComments)
            merged.maxAwards = min(p.maxAwards, merged.maxAwards)
            merged.minAwards = max(p.minAwards, merged.minAwards)

            merged.onlySensitive = p.onlySensitive || merged.onlySensitive
            merged.onlySpoiler = p.onlySpoiler || merged.onlySpoiler

            if let regex = p.postTitleExcludesRegex, !regex.isEmpty {
                merged.postTitleExcludesRegex = regex
            }

            if let regex = p.postTitleContainsRegex, !regex.isEmpty {
                merged.postTitleContainsRegex = regex
            }

            func append(_ current: String?, _ addition: String?) -> String? {
                guard let addition, !addition.isEmpty else {
                    return current
                }
                
                if let current, !current.isEmpty {
                    return current + "," + addition
                } else {
                    return addition
                }
            }

            merged.postTitleExcludesStrings = append(merged.postTitleExcludesStrings, p.postTitleExcludesStrings)
            merged.postTitleContainsStrings = append(merged.postTitleContainsStrings, p.postTitleContainsStrings)
            merged.excludeSubreddits = append(merged.excludeSubreddits, p.excludeSubreddits)
            merged.excludeUsers = append(merged.excludeUsers, p.excludeUsers)
            merged.containFlairs = append(merged.containFlairs, p.containFlairs)
            merged.excludeFlairs = append(merged.excludeFlairs, p.excludeFlairs)
            merged.excludeDomains = append(merged.excludeDomains, p.excludeDomains)
            merged.containDomains = append(merged.containDomains, p.containDomains)

            merged.containTextType = p.containTextType && merged.containTextType
            merged.containLinkType = p.containLinkType && merged.containLinkType
            merged.containImageType = p.containImageType && merged.containImageType
            merged.containGifType = p.containGifType && merged.containGifType
            merged.containVideoType = p.containVideoType && merged.containVideoType
            merged.containGalleryType = p.containGalleryType && merged.containGalleryType
        }

        return merged
    }
}
