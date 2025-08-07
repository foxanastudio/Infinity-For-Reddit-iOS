//
//  CustomizeCommentFilterRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-06.
//

import GRDB

public class CustomizeCommentFilterRepository: CustomizeCommentFilterRepositoryProtocol {
    private let commentFilterDao: CommentFilterDao
    
    init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        self.commentFilterDao = CommentFilterDao(dbPool: resolvedDBPool)
    }
    
    public func saveCommentFilter(_ commentFilter: CommentFilter) -> Bool {
        if commentFilter.id != nil {
            // Updating a comment filter
            do {
                try commentFilterDao.updateCommentFilter(updatedCommentFilter: commentFilter)
                return true
            } catch {
                print("Error updating comment filter - \(error.localizedDescription)")
                return false
            }
        } else {
            do {
                try commentFilterDao.insert(commentFilter: commentFilter)
                return true
            } catch {
                print("Error inserting comment filter - \(error.localizedDescription)")
                return false
            }
        }
    }
}
