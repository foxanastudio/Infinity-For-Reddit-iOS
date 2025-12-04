//
//  PostRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-03.
//

import Combine
import Alamofire
import SwiftyJSON
import GRDB

class PostRepository: PostRepositoryProtocol {
    private let session: Session
    private let postHistoryDao: PostHistoryDao
    
    init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        self.session = resolvedSession
        self.postHistoryDao = PostHistoryDao(dbPool: resolvedDBPool)
    }
    
    func votePost(
        post: Post,
        point: String
    ) async throws {
        do {
            let params = ["dir": point, "id": post.name, "rank": "10"]
            
            try Task.checkCancellation()
            
            _ = try await self.session.request(RedditOAuthAPI.vote(params: params))
                .validate()
                .serializingDecodable(Empty.self, automaticallyCancelling: true)
                .value
        }
    }
    
    func votePostAnonymous(
        post: Post,
        vote: Int
    ) async throws {
        do {
            if vote > 0 {
                try await postHistoryDao.insert(
                    postHistory: PostHistory(
                        username: Account.ANONYMOUS_ACCOUNT.username,
                        postId: post.id,
                        postHistoryType: .upvoted,
                        time: Utils.getCurrentTimeEpoch()
                    )
                )
                try await postHistoryDao.deletePostHistory(username: Account.ANONYMOUS_ACCOUNT.username, postId: post.id, postHistoryType: .downvoted)
            } else if vote == 0 {
                try await postHistoryDao.deletePostHistory(username: Account.ANONYMOUS_ACCOUNT.username, postId: post.id, postHistoryType: .upvoted)
                try await postHistoryDao.deletePostHistory(username: Account.ANONYMOUS_ACCOUNT.username, postId: post.id, postHistoryType: .downvoted)
            } else {
                try await postHistoryDao.insert(
                    postHistory: PostHistory(
                        username: Account.ANONYMOUS_ACCOUNT.username,
                        postId: post.id,
                        postHistoryType: .downvoted,
                        time: Utils.getCurrentTimeEpoch()
                    )
                )
                try await postHistoryDao.deletePostHistory(username: Account.ANONYMOUS_ACCOUNT.username, postId: post.id, postHistoryType: .upvoted)
            }
        }
    }
    
    func savePost(
        post: Post,
        save: Bool
    ) async throws {
        do {
            let params = ["id": post.name]
            
            try Task.checkCancellation()
            
            _ = try await self.session.request(save ? RedditOAuthAPI.saveThing(params: params) : RedditOAuthAPI.unsaveThing(params: params))
                .validate()
                .serializingDecodable(Empty.self, automaticallyCancelling: true)
                .value
        }
    }
    
    func savePostAnonymous(
        post: Post,
        save: Bool
    ) async throws {
        do {
            if save {
                try await postHistoryDao.insert(
                    postHistory: PostHistory(
                        username: Account.ANONYMOUS_ACCOUNT.username,
                        postId: post.id,
                        postHistoryType: .saved,
                        time: Utils.getCurrentTimeEpoch()
                    )
                )
            } else {
                try await postHistoryDao.deletePostHistory(username: Account.ANONYMOUS_ACCOUNT.username, postId: post.id, postHistoryType: .saved)
            }
        }
    }
    
    func readPost(post: Post, account: Account, limitReadPosts: Bool, readPostsLimit: Int) async throws {
        if limitReadPosts {
            if try await postHistoryDao.getReadPostsCount(username: account.username) >= readPostsLimit {
                try await postHistoryDao.deleteOldestReadPosts(username: account.username)
            }
        }
        
        try await postHistoryDao.insert(
            postHistory: PostHistory(
                username: account.username,
                postId: post.id,
                postHistoryType: .readPosts,
                time: Utils.getCurrentTimeEpoch()
            )
        )
    }
}
