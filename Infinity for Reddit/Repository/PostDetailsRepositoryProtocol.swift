//
//  PostDetailsRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-23.
//

import Combine
import Alamofire

public protocol PostDetailsRepositoryProtocol {
    func fetchComments(postId: String, queries: [String: String]) async throws -> PostDetailsRootClass
}
