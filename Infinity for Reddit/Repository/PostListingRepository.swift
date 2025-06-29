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
    enum PostListingRepositoryError: Error {
        case NetworkError(String)
        case JSONDecodingError(String)
    }
    private let session: Session
    private let subredditDao: SubredditDao
    private var subredditOrUserIcons: [String: String] = [:]
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError( "Failed to resolve DatabasePool")
        }
        self.session = resolvedSession
        self.subredditDao = SubredditDao(dbPool: resolvedDBPool)
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
        case .user(let username, let userWhere):
            apiRequest = RedditOAuthAPI.getUserPosts(pathComponents: pathComponents!, queries: queries!)
        case .search:
            apiRequest = RedditOAuthAPI.getSearchPosts(queries: queries!)
        case .multireddit:
            apiRequest = RedditOAuthAPI.getMultiredditPosts(pathComponents: pathComponents!, queries: queries!)
        case .subredditConcat:
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
        
        return PostListingRootClass(fromJson: json).data
    }
    
    public func loadIcon(post: Post, displaySubredditIcon: Bool) async throws {
        try Task.checkCancellation()
        
        guard post.subredditOrUserIcon == nil else { return }
        
        if displaySubredditIcon {
            if "u/\(post.author)" == post.subredditNamePrefixed {
                // User's own subreddit
                if subredditOrUserIcons[post.author] != nil {
                    post.subredditOrUserIcon = subredditOrUserIcons[post.author]
                } else {
                    try await loadUserIcon(post: post)
                }
            } else {
                if subredditOrUserIcons[post.subreddit] != nil {
                    post.subredditOrUserIcon = subredditOrUserIcons[post.subreddit]
                } else {
                    try await loadSubredditIcon(post: post)
                }
            }
        } else {
            if !post.isAuthorDeleted() {
                if subredditOrUserIcons[post.author] != nil {
                    post.subredditOrUserIcon = subredditOrUserIcons[post.author]
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
            post.subredditOrUserIcon = SubredditDetailRootClass(fromJson: json).toSubredditData().iconUrl ?? ""
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
