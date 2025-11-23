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
    func fetchCommentsSingleThread(postId: String, commentId: String, queries: [String: String]) async throws -> PostDetailsRootClass
    func fetchMoreCommentsForCommentMore(params: [String: String]) async throws -> MoreChildren
    func fetchCommentFilter(usageType: CommentFilterUsage.UsageType, nameOfUsage: String) -> CommentFilter
    func loadPostIcon(post: Post, isFromSubredditPostListing: Bool) async throws
    func deleteComment(_ comment: Comment) async throws
    func deletePost(_ post: Post) async throws
    func toggleHidePost(_ post: Post) async throws
    func toggleHidePostAnonymous(_ post: Post) async throws
    func toggleSensitive(_ post: Post) async throws
    func toggleSpoiler(_ post: Post) async throws
    func selectFlair(post: Post, flair: Flair) async throws
}
