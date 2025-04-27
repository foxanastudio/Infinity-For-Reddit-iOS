//
//  PostRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-03.
//

import Combine
import Alamofire

public protocol PostRepositoryProtocol {
    func votePost(post: Post, point: String) async throws
}
