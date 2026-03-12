//
//  HistoryPostsRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-10.
//

import GRDB

class HistoryPostsRepository: HistoryPostsRepositoryProtocol {
    private let postHistoryDao: PostHistoryDao
    
    init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        
        self.postHistoryDao = PostHistoryDao(dbPool: resolvedDBPool)
    }
    
    func getReadPostsIdsByIds(saveReadPosts: Bool, account: Account, postIds: [String]) async -> Set<String> {
        do {
            return saveReadPosts ? Set(try await postHistoryDao.getHistoryPostsIdsByIds(ids: postIds, username: account.username, postHistoryType: .readPosts)) : Set<String>()
        } catch {
            print("getReadPostsIdsByIds failed with error: \(error)")
            return Set<String>()
        }
    }
    
    func getHistoryPostsIdsByIdsAnonymous(postIds: [String], postHistoryType: PostHistoryType) async -> Set<String> {
        do {
            return Set(try await postHistoryDao.getHistoryPostsIdsByIds(ids: postIds, username: Account.ANONYMOUS_ACCOUNT.username, postHistoryType: postHistoryType))
        } catch {
            print("getHistoryPostsIdsByIdsAnonymous failed with error: \(error)")
            return Set<String>()
        }
    }
    
    func getIfExistInHistoryPostsAnonymous(postId: String, postHistoryType: PostHistoryType) async -> Bool {
        do {
            return try await !postHistoryDao.getHistoryPostsIdsByIds(ids: [postId], username: Account.ANONYMOUS_ACCOUNT.username, postHistoryType: postHistoryType).isEmpty
        } catch {
            print("getIfExistInHistoryPostsAnonymous failed with error: \(error)")
            return false
        }
    }
}
