//
//  SubscriptionListingRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-15.
//

import Combine
import Alamofire
import SwiftyJSON
import Foundation

public class SubscriptionListingRepository: SubscriptionListingRepositoryProtocol {
    enum SubscriptionListingRepositoryError: Error {
        case NetworkError(String)
        case JSONDecodingError(String)
    }
    private let session: Session
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
    }
    
    public func fetchSubscriptions(
        queries: [String: String] = [:]
    ) async throws -> SubscriptionListing {
        let data = try await self.session.request(
            RedditOAuthAPI.getSubscribedThings(queries: queries)
        )
            .validate()
            .serializingData()
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw SubscriptionListingRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        // TODO need to handle JSON error
        return SubscriptionListingRootClass(fromJson: json).subscriptionListing
    }
    
    public func fetchMyCustomFeeds() async throws -> MyCustomFeedListing {
        let data = try await self.session.request(
            RedditOAuthAPI.getMyCustomFeeds
        )
            .validate()
            .serializingData()
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw SubscriptionListingRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        return MyCustomFeedListing(fromJson: json)
    }
}
