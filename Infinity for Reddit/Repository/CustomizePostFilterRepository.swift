//
//  CustomizePostFilterRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-01.
//

import GRDB

public class CustomizePostFilterRepository: CustomizePostFilterRepositoryProtocol {
    private let postFilterDao: PostFilterDao
    
    init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        self.postFilterDao = PostFilterDao(dbPool: resolvedDBPool)
    }
    
    public func savePostFilter(_ postFilter: PostFilter) {
        if let id = postFilter.id {
            // Updating a post filter
            do {
                try postFilterDao.updatePostFilter(updatedPostFilter: postFilter)
            } catch {
                print("Error updating postFilter - \(error.localizedDescription)")
            }
        } else {
            do {
                try postFilterDao.insert(postFilter: postFilter)
            } catch {
                print("Error inserting postFilter - \(error.localizedDescription)")
            }
        }
    }
}
