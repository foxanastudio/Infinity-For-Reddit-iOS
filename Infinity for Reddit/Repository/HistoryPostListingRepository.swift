//
//  HistoryPostListingRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-03.
//

import Combine
import Alamofire
import SwiftyJSON
import Foundation
import GRDB

public class HistoryPostListingRepository: HistoryPostListingRepositoryProtocol {
    enum HistoryPostListingRepositoryError: LocalizedError {
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
    private let postHistoryDao: PostHistoryDao
    private let subredditDao: SubredditDao
    private let postFilterDao: PostFilterDao
    private var subredditOrUserIcons: [String: String] = [:]
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in HistoryPostListingRepository")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError( "Failed to resolve DatabasePool in HistoryPostListingRepository")
        }
        self.session = resolvedSession
        self.postHistoryDao = PostHistoryDao(dbPool: resolvedDBPool)
        self.subredditDao = SubredditDao(dbPool: resolvedDBPool)
        self.postFilterDao = PostFilterDao(dbPool: resolvedDBPool)
    }
    
    public func fetchPosts(
        historyPostListingType: HistoryPostListingType,
        username: String,
        before: Int64?
    ) async throws -> HistoryPostListingResult {
        let apiRequest: URLRequestConvertible
        let beforeResult: Int64
        let postHistory = try postHistoryDao.getAllHistoryPosts(username: username, before: before, postHistoryType: historyPostListingType.postHistoryTypeForDB)
        let postFullnames = postHistory.map {
            "t3_\($0.postId)"
        }.joined(separator: ",")
        beforeResult = postHistory.last?.time ?? 0
        apiRequest = RedditOAuthAPI.getInfo(queries: ["id": postFullnames])
        
        try Task.checkCancellation()
        
        let data = try await self.session.request(apiRequest)
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw HistoryPostListingRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        return HistoryPostListingResult(postListing: try PostListingRootClass(fromJson: json).data, before: beforeResult)
    }
    
    public func getPostFilter(historyPostListingType: HistoryPostListingType, externalPostFilter: PostFilter?) -> PostFilter {
        do {
            var postFilters = try postFilterDao.getValidPostFilters(
                usage: PostFilterUsage.UsageType.history.rawValue,
                nameOfUsage: historyPostListingType.postFilterNameOfUsage
            )
            if let externalPostFilter = externalPostFilter {
                postFilters.append(externalPostFilter)
            }
            return PostFilter.mergePostFilter(postFilters)
        } catch {
            return PostFilter()
        }
    }
    
    public func loadIcon(post: Post) async throws {
        try Task.checkCancellation()
        
        guard post.subredditOrUserIcon == nil else { return }
        
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
    }
    
    private func loadSubredditIcon(post: Post) async throws {
        try Task.checkCancellation()
        
        guard post.subredditOrUserIcon == nil else { return }
        
        do {
            let subredditData = try subredditDao.getSubredditDataByName(subredditName: post.subreddit)
            if let subredditData {
                await MainActor.run {
                    post.subredditOrUserIcon = subredditData.iconUrl ?? ""
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
            throw HistoryPostListingRepositoryError.JSONDecodingError(error.localizedDescription)
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
            throw HistoryPostListingRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        try await MainActor.run {
            post.subredditOrUserIcon = try UserDetailRootClass(fromJson: json).toUserData().iconUrl ?? ""
            subredditOrUserIcons[post.author] = post.subredditOrUserIcon
        }
    }
}
