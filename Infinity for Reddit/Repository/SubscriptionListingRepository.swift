//
//  SubscriptionListingRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-15.
//

import Combine
import Alamofire
import SwiftyJSON
import GRDB

class SubscriptionListingRepository: SubscriptionListingRepositoryProtocol {
    private let session: Session
    private let subscribedSubredditDao: SubscribedSubredditDao
    private let subscribedUserDao: SubscribedUserDao
    private let myCustomFeedDao: MyCustomFeedDao
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        self.session = resolvedSession
        self.subscribedSubredditDao = SubscribedSubredditDao(dbPool: resolvedDBPool)
        self.subscribedUserDao = SubscribedUserDao(dbPool: resolvedDBPool)
        self.myCustomFeedDao = MyCustomFeedDao(dbPool: resolvedDBPool)
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
            throw APIError.jsonDecodingError(error.localizedDescription)
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
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        return try MyCustomFeedListing(fromJson: json)
    }
    
    func toggleFavoriteSubreddit(_ subscribedSubreddit: SubscribedSubredditData) async throws {
        try Task.checkCancellation()
        let params = ["sr_name": subscribedSubreddit.name, "make_favorite": String(subscribedSubreddit.isFavorite)]
        _ = try await self.session.request(RedditOAuthAPI.favoriteThing(params: params))
            .validate()
            .serializingDecodable(Empty.self, automaticallyCancelling: true)
            .value
        
        try await subscribedSubredditDao.insert(subscribedSubredditData: subscribedSubreddit)
    }
    
    func toggleFavoriteUser(_ subscribedUser: SubscribedUserData) async throws {
        try Task.checkCancellation()
        let params = ["sr_name": "u_" + subscribedUser.name, "make_favorite": String(subscribedUser.isFavorite)]
        _ = try await self.session.request(RedditOAuthAPI.favoriteThing(params: params))
            .validate()
            .serializingDecodable(Empty.self, automaticallyCancelling: true)
            .value
        
        try await subscribedUserDao.insert(subscribedUserData: subscribedUser)
    }
    
    func toggleFavoriteCustomFeed(_ myCustomFeed: MyCustomFeed) async throws {
        try Task.checkCancellation()
        let params = ["multipath": myCustomFeed.path, "make_favorite": String(myCustomFeed.isFavorite), "api_type": "json"]
        _ = try await self.session.request(RedditOAuthAPI.favoriteCustomFeed(params: params))
            .validate()
            .serializingDecodable(Empty.self, automaticallyCancelling: true)
            .value
        
        try await myCustomFeedDao.insert(myCustomFeed: myCustomFeed)
    }
    
    func unsubscribeFromSubreddit(_ subscribedSubreddit: SubscribedSubredditData) async throws {
        let params = ["action": "unsub", "sr_name": "\(subscribedSubreddit.name)"]
        
        _ = try await self.session.request(RedditOAuthAPI.subsrcribeToSubreddit(params: params))
            .validate()
            .serializingDecodable(Empty.self)
            .value
        
        try? await subscribedSubredditDao.deleteSubscribedSubreddit(subredditName: subscribedSubreddit.name, accountName: AccountViewModel.shared.account.username)
    }
    
    func unfollowUser(_ subscribedUser: SubscribedUserData) async throws {
        let params = ["action": "unsub", "sr_name": "u_\(subscribedUser.name)"]
        
        _ = try await self.session.request(RedditOAuthAPI.subsrcribeToSubreddit(params: params))
            .validate()
            .serializingDecodable(Empty.self)
            .value

        try? await subscribedUserDao.deleteSubscribedUser(name: subscribedUser.name, accountName: AccountViewModel.shared.account.username)
    }
    
    func deleteCustomFeed(_ customFeed: MyCustomFeed) async throws {
        _ = await self.session.request(RedditOAuthAPI.deleteCustomFeed(path: customFeed.path))
            .validate()
            .serializingData()
            .response

        try? await myCustomFeedDao.deleteMyCustomFeed(path: customFeed.path, username: AccountViewModel.shared.account.username)
    }
}
