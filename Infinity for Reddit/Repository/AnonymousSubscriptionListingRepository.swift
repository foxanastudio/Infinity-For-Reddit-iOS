//
//  AnonymousSubscriptionListingRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-09.
//

import GRDB

class AnonymousSubscriptionListingRepository: AnonymousSubscriptionListingRepositoryProtocol {
    private let subscribedSubredditDao: SubscribedSubredditDao
    private let subscribedUserDao: SubscribedUserDao
    private let myCustomFeedDao: MyCustomFeedDao
    
    public init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        self.subscribedSubredditDao = SubscribedSubredditDao(dbPool: resolvedDBPool)
        self.subscribedUserDao = SubscribedUserDao(dbPool: resolvedDBPool)
        self.myCustomFeedDao = MyCustomFeedDao(dbPool: resolvedDBPool)
    }
    
    func toggleFavoriteSubreddit(_ subscribedSubreddit: SubscribedSubredditData) -> Bool {
        do {
            try subscribedSubredditDao.insert(subscribedSubredditData: subscribedSubreddit)
            return true
        } catch {
            print("Failed to toggle favorite subreddit: \(error)")
            return false
        }
    }
    
    func toggleFavoriteUser(_ subscribedUser: SubscribedUserData) -> Bool {
        do {
            try subscribedUserDao.insert(subscribedUserData: subscribedUser)
            return true
        } catch {
            print("Failed to toggle favorite user: \(error)")
            return false
        }
    }
    
    func toggleFavoriteCustomFeed(_ myCustomFeed: MyCustomFeed) -> Bool {
        do {
            try myCustomFeedDao.insert(myCustomFeed: myCustomFeed)
            return true
        } catch {
            print("Failed to toggle favorite custom feed: \(error)")
            return false
        }
    }
    
    func unsubscribeFromSubreddit(_ subscribedSubreddit: SubscribedSubredditData) async throws {
        try subscribedSubredditDao.deleteSubscribedSubreddit(subredditName: subscribedSubreddit.name, accountName: Account.ANONYMOUS_ACCOUNT.username)
    }
    
    func unfollowUser(_ subscribedUser: SubscribedUserData) async throws {
        try subscribedUserDao.deleteSubscribedUser(name: subscribedUser.name, accountName: Account.ANONYMOUS_ACCOUNT.username)
    }
    
    func deleteCustomFeed(_ myCustomFeed: MyCustomFeed) async throws {
        try myCustomFeedDao.deleteMyCustomFeed(path: myCustomFeed.path, username: Account.ANONYMOUS_ACCOUNT.username)
    }
}
