//
//  PostListingRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-05.
//

import Combine

public protocol PostListingRepositoryProtocol {
    func fetchPosts(postListingType: PostListingType, limit: Int) -> AnyPublisher<ListingData, Error>
    func setAccount(_ account: Account)
}
