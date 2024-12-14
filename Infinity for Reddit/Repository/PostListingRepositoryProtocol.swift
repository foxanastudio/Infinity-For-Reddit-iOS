//
//  PostListingRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-05.
//

import Combine
import Alamofire

public protocol PostListingRepositoryProtocol {
    func fetchPosts(postListingType: PostListingType, pathComponents: [String: String]?, queries: [String: String]?, params: [String: String]?) -> AnyPublisher<ListingData, Error>
    func setAccount(_ account: Account)
}
