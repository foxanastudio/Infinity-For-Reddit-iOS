//
//  CustomizeCommentFilterRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-06.
//

public protocol CustomizeCommentFilterRepositoryProtocol {
    func saveCommentFilter(_ filter: CommentFilter) -> Bool
}
