//
//  SubscriptionListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-15.
//

import Foundation
import Combine
import GRDB

public class SubscriptionListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var subredditSubscriptions: [Subscription] = []
    @Published var userSubscriptions: [Subscription] = []
    private var subscriptionsPrivate: [Subscription] = []
    @Published var myCustomFeeds: [CustomFeed] = []
    @Published var isLoadingSubscriptions: Bool = false
    @Published var isLoadingMyCustomFeeds: Bool = false
    private var after: String? = nil
    private var cancellables = Set<AnyCancellable>()
    
    public let subscriptionListingRepository: SubscriptionListingRepositoryProtocol
    
    // MARK: - Initializer
    init(subscriptionListingRepository: SubscriptionListingRepositoryProtocol) {
        self.subscriptionListingRepository = subscriptionListingRepository
    }
    
    // MARK: - Methods
    
    public func loadSubscriptions() {
        guard !isLoadingSubscriptions || (isLoadingSubscriptions && after != nil && after?.isEmpty != true) else { return }
        
        isLoadingSubscriptions = true
        
        subscriptionListingRepository.fetchSubscriptions(
            queries: ["limit": "100", "after": after ?? ""]
        )
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        print("Error fetching subscriptions: \(error)")
                        self?.after = nil
                        self?.isLoadingSubscriptions = false
                    }
                }
            }, receiveValue: { [weak self] subscriptionListing in
                guard let self = self else { return }
                if (subscriptionListing.subscriptions.isEmpty) {
                    // No more subscriptions
                    var subreddits = [Subscription]()
                    var users = [Subscription]()
                    for subscription in self.subscriptionsPrivate {
                        if subscription.subredditType == "user" {
                            subscription.displayName = String(subscription.displayName[subscription.displayName.index(subscription.displayName.startIndex, offsetBy: 2)...])
                            users.append(subscription)
                        } else {
                            subreddits.append(subscription)
                        }
                    }
                    
                    users.sort { $0.displayName.lowercased() < $1.displayName.lowercased() }
                    subreddits.sort { $0.displayName.lowercased() < $1.displayName.lowercased() }
                    
                    DispatchQueue.main.async {
                        self.after = nil
                        self.isLoadingSubscriptions = false
                        self.subredditSubscriptions = subreddits
                        self.userSubscriptions = users
                    }
                } else {
                    self.after = subscriptionListing.after
                    
                    subscriptionsPrivate.append(contentsOf: subscriptionListing.subscriptions)
                    
                    if self.after == nil || self.after?.isEmpty == true {
                        var subreddits = [Subscription]()
                        var users = [Subscription]()
                        for subscription in self.subscriptionsPrivate {
                            if subscription.subredditType == "user" {
                                subscription.displayName = String(subscription.displayName[subscription.displayName.index(subscription.displayName.startIndex, offsetBy: 2)...])
                                users.append(subscription)
                            } else {
                                subreddits.append(subscription)
                            }
                        }
                        
                        users.sort { $0.displayName.lowercased() < $1.displayName.lowercased() }
                        subreddits.sort { $0.displayName.lowercased() < $1.displayName.lowercased() }
                        
                        DispatchQueue.main.async {
                            self.after = nil
                            self.isLoadingSubscriptions = false
                            self.subredditSubscriptions = subreddits
                            self.userSubscriptions = users
                        }
                    } else {
                        loadSubscriptions()
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    public func loadMyCustomFeeds() {
        guard !isLoadingMyCustomFeeds else { return }
        
        isLoadingSubscriptions = true
        
        subscriptionListingRepository.fetchMyCustomFeeds()
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        print("Error fetching custom feeds: \(error)")
                        self?.isLoadingMyCustomFeeds = false
                    }
                }
            }, receiveValue: { [weak self] myCustomFeedListing in
                guard let self = self else { return }
                myCustomFeedListing.customFeeds.sort { $0.displayName < $1.displayName }
                DispatchQueue.main.async {
                    self.isLoadingMyCustomFeeds = false
                    self.myCustomFeeds = myCustomFeedListing.customFeeds
                }
            })
            .store(in: &cancellables)
    }
    
    func refreshSubscriptions(account: Account) {
        // This is for user switching accounts. We have to force clear all load
        cancellables.forEach { $0.cancel() }
        
        isLoadingSubscriptions = false
        isLoadingMyCustomFeeds = false
        
        after = nil
        subscriptionsPrivate = []
        
        loadSubscriptions()
        loadMyCustomFeeds()
    }
    
//    private func insertSubscribedThings(
//        dbPool: DatabasePool,
//        accountName: String,
//        subscribedSubredditDataList: [SubscribedSubredditData]?,
//        subscribedUserDataList: [SubscribedUserData]?,
//        subredditDataList: [SubredditData]?,
//        completion: @escaping () -> Void
//    ) {
//        DispatchQueue.global(qos: .background).async {
//            do {
//                try dbPool.write { db in
//                    // Check if account exists
//                    guard accountName != Account.ANONYMOUS_ACCOUNT,
//                          let _ = try Account.fetchOne(db, key: accountName) else {
//                        DispatchQueue.main.async {
//                            completion()
//                        }
//                        return
//                    }
//
//                    // Handle subscribed subreddits
//                    if let subredditList = subscribedSubredditDataList {
//                        let dao = SubscribedSubredditDao(dbPool: dbPool)
//                        let existingSubreddits = try dao.getAllSubscribedSubredditsList(accountName: accountName)
//
//                        let unsubscribedSubreddits = existingSubreddits.filter { existing in
//                            !subredditList.contains { $0.name == existing.name }
//                        }
//
//                        for unsubscribed in unsubscribedSubreddits {
//                            try dao.deleteSubscribedSubreddit(subredditName: unsubscribed.name ?? "", accountName: accountName)
//                        }
//
//                        try dao.insertAll(subscribedSubredditData: subredditList)
//                    }
//
//                    // Handle subscribed users
//                    if let userList = subscribedUserDataList {
//                        let dao = SubscribedUserDao(dbPool: dbPool)
//                        let existingUsers = try dao.getAllSubscribedUsersList(accountName: accountName)
//
//                        let unsubscribedUsers = existingUsers.filter { existing in
//                            !userList.contains { $0.name == existing.name }
//                        }
//
//                        for unsubscribed in unsubscribedUsers {
//                            try dao.deleteSubscribedUser(userName: unsubscribed.name ?? "", accountName: accountName)
//                        }
//
//                        try dao.insertAll(subscribedUserData: userList)
//                    }
//
//                    // Handle subreddit data
//                    if let subredditList = subredditDataList {
//                        let dao = SubredditDao(dbPool: dbPool)
//                        try dao.insertAll(subredditData: subredditList)
//                    }
//                }
//
//                DispatchQueue.main.async {
//                    completion()
//                }
//            } catch {
//                print("Error updating subscribed things: \(error)")
//                DispatchQueue.main.async {
//                    completion()
//                }
//            }
//        }
//    }
}
