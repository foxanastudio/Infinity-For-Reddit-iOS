//
//  ReadPostsRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-10.
//

import GRDB

class ReadPostsRepository: ReadPostsRepositoryProtocol {
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
            return readPostEnabled ? Set(try readPostDao.getReadPostsIdsByIds(ids: postIds, username: account.username)) : Set<String>()
        } catch {
            print("getReadPostsIdsByIds failed with error: \(error)")
            return Set<String>()
        }
    }
}
