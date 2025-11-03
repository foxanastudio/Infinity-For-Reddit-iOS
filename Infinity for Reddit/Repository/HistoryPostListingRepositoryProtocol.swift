//
//  HistoryPostListingRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-03.
//

import Combine
import Alamofire

public protocol HistoryPostListingRepositoryProtocol {
    func fetchPosts(historyPostListingType: HistoryPostListingType, username: String, before: Int64?) async throws -> (postListing: PostListing, before: Int64)
    func getPostFilter(historyPostListingType: HistoryPostListingType, externalPostFilter: PostFilter?) -> PostFilter
    func loadIcon(post: Post) async throws
}
