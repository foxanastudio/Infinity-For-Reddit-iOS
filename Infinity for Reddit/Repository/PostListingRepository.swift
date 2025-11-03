//
//  PostListingRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-05.
//

import Combine
import Alamofire
import SwiftyJSON
import Foundation
import GRDB

public class PostListingRepository: PostListingRepositoryProtocol {
    enum PostListingRepositoryError: LocalizedError {
        case NetworkError(String)
        case JSONDecodingError(String)
        
        var errorDescription: String? {
            switch self {
            case .NetworkError(let message):
                return message
            case .JSONDecodingError(let message):
                return message
            }
        }
    }
    
    private let session: Session
    private let subredditDao: SubredditDao
    private let postFilterDao: PostFilterDao
    private let subscribedSubredditDao: SubscribedSubredditDao
    private var subredditOrUserIcons: [String: String] = [:]
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in PostListingRepository")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError( "Failed to resolve DatabasePool in PostListingRepository")
        }
        self.session = resolvedSession
        self.subredditDao = SubredditDao(dbPool: resolvedDBPool)
        self.postFilterDao = PostFilterDao(dbPool: resolvedDBPool)
        self.subscribedSubredditDao = SubscribedSubredditDao(dbPool: resolvedDBPool)
    }
    
    public func fetchPosts(
        postListingType: PostListingType,
        pathComponents: [String: String]? = nil,
        queries: [String: String]? = [:],
        params: [String: String]? = [:]
    ) async throws -> PostListing {
        let apiRequest: URLRequestConvertible
        switch postListingType {
        case .frontPage:
            apiRequest = RedditOAuthAPI.getFrontPagePosts(pathComponents: pathComponents!, queries: queries!)
        case .subreddit:
            apiRequest = RedditOAuthAPI.getSubredditPosts(pathComponents: pathComponents!, queries: queries!)
        case .user:
            apiRequest = RedditOAuthAPI.getUserPosts(pathComponents: pathComponents!, queries: queries!)
        case .search(_, let searchInSubredditOrUserName, let searchInMultiReddit, let searchInThingType):
            switch searchInThingType {
            case .all:
                apiRequest = RedditOAuthAPI.getSearchPosts(queries: queries!)
            case .subreddit:
                if let name = searchInSubredditOrUserName {
                    apiRequest = RedditOAuthAPI.getSearchPostsInSpecificThing(pathComponents: ["name" : "r/\(name)"], queries: queries!)
                } else {
                    apiRequest = RedditOAuthAPI.getSearchPosts(queries: queries!)
                }
            case .user:
                if let name = searchInSubredditOrUserName {
                    apiRequest = RedditOAuthAPI.getSearchPostsInSpecificThing(pathComponents: ["name" : "r/u_\(name)"], queries: queries!)
                } else {
                    apiRequest = RedditOAuthAPI.getSearchPosts(queries: queries!)
                }
            case .customFeed:
                if let path = searchInMultiReddit {
                    apiRequest = RedditOAuthAPI.getSearchPostsInSpecificThing(pathComponents: ["name" : path], queries: queries!)
                } else {
                    apiRequest = RedditOAuthAPI.getSearchPosts(queries: queries!)
                }
            }
        case .customFeed:
            apiRequest = RedditOAuthAPI.getCustomFeedPosts(pathComponents: pathComponents!, queries: queries!)
        case .anonymousFrontPage:
            apiRequest = RedditOAuthAPI.getSubredditConcatPosts(pathComponents: pathComponents!, queries: queries!)
        }
        
        try Task.checkCancellation()
        
        let data = try await self.session.request(apiRequest)
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw PostListingRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        return try PostListingRootClass(fromJson: json).data
    }
    
    public func getAnonymousSubscriptionsConcatenated() -> String {
        do {
            let subscribedSubreddits = try subscribedSubredditDao.getAllSubscribedSubredditsList(accountName: Account.ANONYMOUS_ACCOUNT.username)
            return subscribedSubreddits.map {
                $0.name
            }.joined(separator: "+")
        } catch {
            return ""
        }
    }
    
    public func getPostFilter(postListingType: PostListingType, externalPostFilter: PostFilter?) -> PostFilter {
        do {
            var postFilters = try postFilterDao.getValidPostFilters(usage: postListingType.postFilterUsageType.rawValue, nameOfUsage: postListingType.postFilterNameOfUsage)
            if let externalPostFilter = externalPostFilter {
                postFilters.append(externalPostFilter)
            }
            return PostFilter.mergePostFilter(postFilters)
        } catch {
            return PostFilter()
        }
    }
    
    public func loadIcon(post: Post, displaySubredditIcon: Bool) async throws {
        try Task.checkCancellation()
        
        guard post.subredditOrUserIcon == nil else { return }
        
        if displaySubredditIcon {
            if "u/\(post.author ?? "")" == post.subredditNamePrefixed {
                // User's own subreddit
                if subredditOrUserIcons[post.author] != nil {
                    await MainActor.run {
                        post.subredditOrUserIcon = subredditOrUserIcons[post.author]
                    }
                } else {
                    try await loadUserIcon(post: post)
                }
            } else {
                if subredditOrUserIcons[post.subreddit] != nil {
                    await MainActor.run {
                        post.subredditOrUserIcon = subredditOrUserIcons[post.subreddit]
                    }
                } else {
                    try await loadSubredditIcon(post: post)
                }
            }
        } else {
            if !post.isAuthorDeleted() {
                if subredditOrUserIcons[post.author] != nil {
                    await MainActor.run {
                        post.subredditOrUserIcon = subredditOrUserIcons[post.author]
                    }
                } else {
                    try await loadUserIcon(post: post)
                }
            }
        }
    }
    
    private func loadSubredditIcon(post: Post) async throws {
        try Task.checkCancellation()
        
        guard post.subredditOrUserIcon == nil else { return }
        
        do {
            let subredditDataList = try subredditDao.getSubredditDataByName(name: post.subreddit)
            if !subredditDataList.isEmpty {
                await MainActor.run {
                    post.subredditOrUserIcon = subredditDataList[0].iconUrl ?? ""
                    subredditOrUserIcons[post.subreddit] = post.subredditOrUserIcon
                }
                return
            }
        } catch {
            // Ignore
        }
        
        let data = try await self.session.request(
            RedditOAuthAPI.getSubredditData(subredditName: post.subreddit)
        )
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw PostListingRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        await MainActor.run {
            post.subredditOrUserIcon = try? SubredditDetailRootClass(fromJson: json).toSubredditData().iconUrl ?? ""
            subredditOrUserIcons[post.subreddit] = post.subredditOrUserIcon
        }
    }
    
    private func loadUserIcon(post: Post) async throws {
        try Task.checkCancellation()
        
        guard post.subredditOrUserIcon == nil else { return }
        
        let data = try await self.session.request(
            RedditAPI.getUserData(username: post.author)
        )
        .validate()
        .serializingData()
        .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw PostListingRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        await MainActor.run {
            post.subredditOrUserIcon = UserDetailRootClass(fromJson: json).toUserData().iconUrl ?? ""
            subredditOrUserIcons[post.author] = post.subredditOrUserIcon
        }
    }
}
