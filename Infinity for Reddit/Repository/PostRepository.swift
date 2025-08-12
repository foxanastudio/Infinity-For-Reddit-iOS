//
//  PostRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-03.
//

import Combine
import Alamofire
import SwiftyJSON
import Foundation
import GRDB

class PostRepository: PostRepositoryProtocol {
    enum PostRepositoryError: Error {
        case NetworkError(String)
        case JSONDecodingError(String)
    }
    
    private let session: Session
    private let readPostDao: ReadPostDao
    
    init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        self.session = resolvedSession
        self.readPostDao = ReadPostDao(dbPool: resolvedDBPool)
    }
    
    func votePost(
        post: Post,
        point: String
    ) async throws {
        do {
            let params = ["dir": point, "id": post.name!, "rank": "10"]
            
            try Task.checkCancellation()
            
            _ = try await self.session.request(RedditOAuthAPI.vote(params: params))
                .validate()
                .serializingDecodable(Empty.self, automaticallyCancelling: true)
                .value
        }
    }
    
    func savePost(
        post: Post,
        save: Bool
    ) async throws {
        do {
            let params = ["id": post.name!]
            
            try Task.checkCancellation()
            
            _ = try await self.session.request(save ? RedditOAuthAPI.saveThing(params: params) : RedditOAuthAPI.unsaveThing(params: params))
                .validate()
                .serializingDecodable(Empty.self, automaticallyCancelling: true)
                .value
        }
    }
    
    func readPost(post: Post, account: Account, limitReadPosts: Bool, readPostsLimit: Int) async throws {
        guard !account.isAnonymous() else {
            return
        }
        
        if limitReadPosts {
            if try await readPostDao.getReadPostsCount(username: account.username) >= readPostsLimit {
                try await readPostDao.deleteOldestReadPosts(username: account.username)
            }
        }
        
        try await readPostDao.insert(
            readPost: ReadPost(
                username: account.username,
                postId: post.id,
                time: Int64(Date().timeIntervalSince1970)
            )
        )
    }
}
