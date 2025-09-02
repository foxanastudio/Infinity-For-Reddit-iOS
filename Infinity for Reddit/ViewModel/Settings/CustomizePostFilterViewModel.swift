//
//  CustomizePostFilterViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-01.
//

import Foundation

public class CustomizePostFilterViewModel: ObservableObject {
    @Published private var id: Int? = nil
    @Published public var name: String = "New Filter"
    @Published public var showText = true
    @Published public var showLink = true
    @Published public var showImage = true
    @Published public var showGif = true
    @Published public var showVideo = true
    @Published public var showGallery = true
    @Published public var onlySensitive = false
    @Published public var onlySpoiler = false
    @Published public var excludesKeywords: String = ""
    @Published public var containsKeywords: String = ""
    @Published public var excludesRegex: String = ""
    @Published public var containsRegex: String = ""
    @Published public var excludeSubreddits: String = ""
    @Published public var excludeUsers: String = ""
    @Published public var excludeFlairs: String = ""
    @Published public var containFlairs: String = ""
    @Published public var excludeDomains: String = ""
    @Published public var containDomains: String = ""
    @Published public var minVote: Int = -1
    @Published public var minVoteString: String = "-1"
    @Published public var maxVote: Int = -1
    @Published public var maxVoteString: String = "-1"
    @Published public var minComments: Int = -1
    @Published public var minCommentsString: String = "-1"
    @Published public var maxComments: Int = -1
    @Published public var maxCommentsString: String = "-1"
    
    private let customizePostFilterRepository: CustomizePostFilterRepositoryProtocol
    
    init(postFilter: PostFilter?, customizePostFilterRepository: CustomizePostFilterRepositoryProtocol) {
        if let postFilter = postFilter {
            id = postFilter.id
            name = postFilter.name
            showText = postFilter.containTextType
            showLink = postFilter.containLinkType
            showImage = postFilter.containImageType
            showGif = postFilter.containGifType
            showVideo = postFilter.containVideoType
            showGallery = postFilter.containGalleryType
            onlySensitive = postFilter.onlySensitive
            onlySpoiler = postFilter.onlySpoiler
            excludesKeywords = postFilter.postTitleExcludesStrings ?? ""
            containsKeywords = postFilter.postTitleContainsStrings ?? ""
            excludesRegex = postFilter.postTitleExcludesRegex ?? ""
            containsRegex = postFilter.postTitleContainsRegex ?? ""
            excludeSubreddits = postFilter.excludeSubreddits ?? ""
            excludeUsers = postFilter.excludeUsers ?? ""
            excludeFlairs = postFilter.excludeFlairs ?? ""
            containFlairs = postFilter.containFlairs ?? ""
            excludeDomains = postFilter.excludeDomains ?? ""
            containDomains = postFilter.containDomains ?? ""
            minVote = postFilter.minVote
            minVoteString = String(postFilter.minVote)
            maxVote = postFilter.maxVote
            maxVoteString = String(postFilter.maxVote)
            minComments = postFilter.minComments
            minCommentsString = String(postFilter.minComments)
            maxComments = postFilter.maxComments
            maxCommentsString = String(postFilter.maxComments)
        }
        
        self.customizePostFilterRepository = customizePostFilterRepository
    }
    
    func savePostFilter() -> Bool {
        let postFilter = PostFilter(
            id: id,
            name: name,
            maxVote: maxVote,
            minVote: minVote,
            maxComments: maxComments,
            minComments: minComments,
            onlySensitive: onlySensitive,
            onlySpoiler: onlySpoiler,
            postTitleExcludesRegex: excludesRegex,
            postTitleContainsRegex: containsRegex,
            postTitleExcludesStrings: excludesKeywords,
            postTitleContainsStrings: containsKeywords,
            excludeSubreddits: excludeSubreddits,
            excludeUsers: excludeUsers,
            containFlairs: containFlairs,
            excludeFlairs: excludeFlairs,
            excludeDomains: excludeDomains,
            containDomains: containDomains,
            containTextType: showText,
            containLinkType: showLink,
            containImageType: showImage,
            containGifType: showGif,
            containVideoType: showVideo,
            containGalleryType: showGallery
        )
        
        return customizePostFilterRepository.savePostFilter(postFilter)
    }
    
    func getPostFilter() -> PostFilter {
        return PostFilter(
            id: id,
            name: name,
            maxVote: maxVote,
            minVote: minVote,
            maxComments: maxComments,
            minComments: minComments,
            onlySensitive: onlySensitive,
            onlySpoiler: onlySpoiler,
            postTitleExcludesRegex: excludesRegex,
            postTitleContainsRegex: containsRegex,
            postTitleExcludesStrings: excludesKeywords,
            postTitleContainsStrings: containsKeywords,
            excludeSubreddits: excludeSubreddits,
            excludeUsers: excludeUsers,
            containFlairs: containFlairs,
            excludeFlairs: excludeFlairs,
            excludeDomains: excludeDomains,
            containDomains: containDomains,
            containTextType: showText,
            containLinkType: showLink,
            containImageType: showImage,
            containGifType: showGif,
            containVideoType: showVideo,
            containGalleryType: showGallery
        )
    }
}
