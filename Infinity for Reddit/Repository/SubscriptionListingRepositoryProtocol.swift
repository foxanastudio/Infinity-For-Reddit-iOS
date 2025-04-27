//
//  SubscriptionListingRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-15.
//

import Combine
import Alamofire

public protocol SubscriptionListingRepositoryProtocol {
    func fetchSubscriptions(queries: [String: String]) async throws -> SubscriptionListing
    func fetchMyCustomFeeds() async throws -> MyCustomFeedListing
}
