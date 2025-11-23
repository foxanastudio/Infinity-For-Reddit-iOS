//
//  PostListingRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-05.
//

import Combine
import Alamofire

public protocol PostListingRepositoryProtocol {
    func fetchPosts(postListingType: PostListingType, pathComponents: [String: String]?, queries: [String: String]?, params: [String: String]?) async throws -> PostListing
    func getAnonymousSubscriptionsConcatenated() -> String
    func getAnonymousCustomThemeSubredditsConcatenated(myCustomFeed: MyCustomFeed) -> String
    func getPostFilter(postListingType: PostListingType, externalPostFilter: PostFilter?) -> PostFilter
    func loadIcon(post: Post, displaySubredditIcon: Bool) async throws
}
