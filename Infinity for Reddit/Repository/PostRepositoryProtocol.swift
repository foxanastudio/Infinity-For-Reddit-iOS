//
//  PostRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-03.
//

import Combine
import Alamofire

protocol PostRepositoryProtocol {
    func votePost(post: Post, point: String) async throws
    func votePostAnonymous(post: Post, vote: Int) async throws
    func savePost(post: Post, save: Bool) async throws
    func savePostAnonymous(post: Post, save: Bool) async throws
    func readPost(post: Post, account: Account, limitReadPosts: Bool, readPostsLimit: Int) async throws
}
