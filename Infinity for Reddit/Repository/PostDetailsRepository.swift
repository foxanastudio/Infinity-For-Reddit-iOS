//
//  PostDetailsRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-23.
//

import Combine
import Alamofire
import SwiftyJSON
import Foundation
import GRDB

public class PostDetailsRepository: PostDetailsRepositoryProtocol {
    enum PostDetailsRepositoryError: LocalizedError {
        case NetworkError(String)
        case JSONDecodingError(String)
        case commentIdNotFound
        case postIdNotFound
        
        var errorDescription: String? {
            switch self {
            case .NetworkError(let message):
                return message
            case .JSONDecodingError(let message):
                return message
            case .commentIdNotFound:
                return "Comment ID not found"
            case .postIdNotFound:
                return "Post ID not found"
            }
        }
    }
    
    private let session: Session
    private let subredditDao: SubredditDao
    private let commentFilterDao: CommentFilterDao
    private let postHistoryDao: PostHistoryDao
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError( "Failed to resolve DatabasePool")
        }
        self.session = resolvedSession
        self.subredditDao = SubredditDao(dbPool: resolvedDBPool)
        self.commentFilterDao = CommentFilterDao(dbPool: resolvedDBPool)
        self.postHistoryDao = PostHistoryDao(dbPool: resolvedDBPool)
    }
    
    public func fetchComments(
        postId: String,
        queries: [String: String] = [:]
    ) async throws -> PostDetailsRootClass {
        try Task.checkCancellation()
        
        let data = try await self.session.request(
            RedditOAuthAPI.getPostAndCommentsById(postId: postId, queries: queries)
        )
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw PostDetailsRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        let postDetails = try PostDetailsRootClass(fromJson: json)
        postDetails.makeCommentList()
        print(postDetails.comments.count)
        
        return postDetails
    }
    
    public func fetchCommentsSingleThread(
        postId: String,
        commentId: String,
        queries: [String: String] = [:]
    ) async throws -> PostDetailsRootClass {
        try Task.checkCancellation()
        
        let data = try await self.session.request(
            RedditOAuthAPI.getPostAndCommentsSingleThreadById(postId: postId, commentId: commentId, queries: queries)
        )
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw PostDetailsRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        let postDetails = try PostDetailsRootClass(fromJson: json)
        postDetails.makeCommentList()
        print(postDetails.comments.count)
        
        return postDetails
    }
    
    public func fetchMoreCommentsForCommentMore(params: [String: String]) async throws -> MoreChildren {
        try Task.checkCancellation()
        
        let data = try await self.session.request(
            RedditOAuthAPI.getMoreCommentsForCommentMore(params: params)
        )
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw PostDetailsRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        let moreChildren = MoreChildren(fromJson: json)
        print(moreChildren.commentItems.count)
        
        return moreChildren
    }
    
    public func fetchCommentFilter(usageType: CommentFilterUsage.UsageType, nameOfUsage: String) -> CommentFilter {
        do {
            let commentFilters = try commentFilterDao.getValidCommentFilters(usageType: usageType, nameOfUsage: nameOfUsage)
            return CommentFilter.mergeCommentFilter(commentFilters)
        } catch {
            return CommentFilter()
        }
    }
    
    public func loadPostIcon(post: Post, isFromSubredditPostListing: Bool) async throws {
        try Task.checkCancellation()
        
        guard post.subredditOrUserIconInPostDetails == nil else { return }
        
        if "u/\(post.author ?? "")" == post.subredditNamePrefixed {
            // User's own subreddit
            try await loadUserIcon(post: post)
        } else {
            try await loadSubredditIcon(post: post)
        }
    }
    
    private func loadSubredditIcon(post: Post) async throws {
        try Task.checkCancellation()
        
        guard post.subredditOrUserIconInPostDetails == nil else { return }
        
        do {
            let subredditDataList = try subredditDao.getSubredditDataByName(name: post.subreddit)
            if !subredditDataList.isEmpty {
                await MainActor.run {
                    post.subredditOrUserIconInPostDetails = subredditDataList[0].iconUrl ?? ""
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
            throw PostDetailsRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        await MainActor.run {
            post.subredditOrUserIconInPostDetails = try? SubredditDetailRootClass(fromJson: json).toSubredditData().iconUrl ?? ""
        }
    }
    
    private func loadUserIcon(post: Post) async throws {
        try Task.checkCancellation()
        
        guard post.subredditOrUserIconInPostDetails == nil else { return }
        
        let data = try await self.session.request(
            RedditAPI.getUserData(username: post.author)
        )
        .validate()
        .serializingData()
        .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw PostDetailsRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        await MainActor.run {
            post.subredditOrUserIconInPostDetails = UserDetailRootClass(fromJson: json).toUserData().iconUrl ?? ""
        }
    }
    
    public func deleteComment(_ comment: Comment) async throws {
        guard let name = comment.name else {
            throw PostDetailsRepositoryError.commentIdNotFound
        }
        let params = ["id": name]
        
        try Task.checkCancellation()
        
        _ = try await self.session.request(RedditOAuthAPI.deletePostOrComment(params: params))
            .validate()
            .serializingDecodable(Empty.self, automaticallyCancelling: true)
            .value
    }
    
    public func deletePost(_ post: Post) async throws {
        guard let name = post.name else {
            throw PostDetailsRepositoryError.postIdNotFound
        }
        let params = ["id": name]
        
        try Task.checkCancellation()
        
        _ = try await self.session.request(RedditOAuthAPI.deletePostOrComment(params: params))
            .validate()
            .serializingDecodable(Empty.self, automaticallyCancelling: true)
            .value
    }
    
    public func toggleHidePost(_ post: Post) async throws {
        guard let name = post.name else {
            throw PostDetailsRepositoryError.postIdNotFound
        }
        let params = ["id": name]
        
        try Task.checkCancellation()
        
        _ = try await self.session.request(post.hidden ? RedditOAuthAPI.unhidePost(params: params) : RedditOAuthAPI.hidePost(params: params))
            .validate()
            .serializingDecodable(Empty.self, automaticallyCancelling: true)
            .value
    }
    
    public func toggleHidePostAnonymous(_ post: Post) async throws {
        do {
            if !post.hidden {
                try await postHistoryDao.insert(
                    postHistory: PostHistory(
                        username: Account.ANONYMOUS_ACCOUNT.username,
                        postId: post.id,
                        postHistoryType: .hidden,
                        time: Int64(Date().timeIntervalSince1970)
                    )
                )
            } else {
                try await postHistoryDao.deletePostHistory(username: Account.ANONYMOUS_ACCOUNT.username, postId: post.id, postHistoryType: .hidden)
            }
        }
    }
}
