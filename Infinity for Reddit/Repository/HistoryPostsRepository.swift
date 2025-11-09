//
//  HistoryPostsRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-10.
//

import GRDB

class HistoryPostsRepository: HistoryPostsRepositoryProtocol {
    private let readPostDao: PostHistoryDao
    
    init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        
        self.readPostDao = PostHistoryDao(dbPool: resolvedDBPool)
    }
    
    func getReadPostsIdsByIds(readPostEnabled: Bool, account: Account, postIds: [String]) -> Set<String> {
        guard !account.isAnonymous() else {
            return Set<String>()
        }
        
        do {
            return readPostEnabled ? Set(try readPostDao.getHistoryPostsIdsByIds(ids: postIds, username: account.username, postHistoryType: .readPosts)) : Set<String>()
        } catch {
            print("getReadPostsIdsByIds failed with error: \(error)")
            return Set<String>()
        }
    }
    
    func getHistoryPostsIdsByIdsAnonymous(account: Account, postIds: [String], postHistoryType: PostHistoryType) -> Set<String> {
        do {
            return Set(try readPostDao.getHistoryPostsIdsByIds(ids: postIds, username: Account.ANONYMOUS_ACCOUNT.username, postHistoryType: postHistoryType))
        } catch {
            print("getHistoryPostsIdsByIdsAnonymous failed with error: \(error)")
            return Set<String>()
        }
    }
    
    func getIfExistInHistoryPostsAnonymous(account: Account, postId: String, postHistoryType: PostHistoryType) -> Bool {
        do {
            return try !readPostDao.getHistoryPostsIdsByIds(ids: [postId], username: Account.ANONYMOUS_ACCOUNT.username, postHistoryType: postHistoryType).isEmpty
        } catch {
            print("getIfExistInHistoryPostsAnonymous failed with error: \(error)")
            return false
        }
    }
}
