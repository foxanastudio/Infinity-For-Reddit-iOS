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
    
    public func savePostFilter(_ postFilter: PostFilter) -> Bool {
        if postFilter.id != nil {
            // Updating a post filter
            do {
                try postFilterDao.updatePostFilter(updatedPostFilter: postFilter)
                return true
            } catch {
                print("Error updating postFilter - \(error.localizedDescription)")
                return false
            }
        } else {
            do {
                try postFilterDao.insert(postFilter: postFilter)
                return true
            } catch {
                print("Error inserting postFilter - \(error.localizedDescription)")
                return false
            }
        }
    }
}
