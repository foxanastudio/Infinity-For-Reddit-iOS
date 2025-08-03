//
//  PostFilterRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-02.
//

import GRDB

public class PostFilterRepository: PostFilterRepositoryProtocol {
    private let postFilterDao: PostFilterDao
    
    init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        self.postFilterDao = PostFilterDao(dbPool: resolvedDBPool)
    }
    
    public func deletePostFilter(id: Int) {
        do {
            try postFilterDao.deletePostFilter(id: id)
            
        } catch {
            print("Error deleting \(id): \(error)")
        }
    }
}
