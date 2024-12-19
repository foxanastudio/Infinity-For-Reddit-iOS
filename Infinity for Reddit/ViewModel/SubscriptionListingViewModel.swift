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
    private let operationqueue: OperationQueue
    private let dbPool: DatabasePool
    
    public let subscriptionListingRepository: SubscriptionListingRepositoryProtocol
    
    // MARK: - Initializer
    init(subscriptionListingRepository: SubscriptionListingRepositoryProtocol) {
        self.subscriptionListingRepository = subscriptionListingRepository
        guard let resolvedOperationQueue = DependencyManager.shared.container.resolve(OperationQueue.self) else {
            fatalError("Could not resolve OperationQueue")
        }
        
        guard let resolvedDatabasePool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Could not resolve DatabasePool")
        }
        
        self.operationqueue = resolvedOperationQueue
        self.dbPool = resolvedDatabasePool
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
                
                subreddits.sort { $0.displayName.lowercased() < $1.displayName.lowercased() }
                users.sort { $0.displayName.lowercased() < $1.displayName.lowercased() }
                
                insertSubscribedThings(subredditSubscriptions: subreddits, userSubscriptions: users)
                
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
                    
                    subreddits.sort { $0.displayName.lowercased() < $1.displayName.lowercased() }
                    users.sort { $0.displayName.lowercased() < $1.displayName.lowercased() }
                    
                    insertSubscribedThings(subredditSubscriptions: subreddits, userSubscriptions: users)
                    
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
    
    private func insertSubscribedThings(subredditSubscriptions: [Subscription], userSubscriptions: [Subscription]) {
        do {
            // Check if account exists
            guard !AccountViewModel.shared.account.isAnonymous(),
                  let _ = try AccountDao(dbPool: dbPool).getAccount(username: AccountViewModel.shared.account.username) else {
                return
            }
            
            let accountName = AccountViewModel.shared.account.username
            
            // Handle subscribed subreddits
            let subscribedSubredditDao = SubscribedSubredditDao(dbPool: dbPool)
            let existingSubreddits = try subscribedSubredditDao.getAllSubscribedSubredditsList(accountName: accountName)
            
            let unsubscribedSubreddits = existingSubreddits.filter { existing in
                !subredditSubscriptions.contains { $0.name == existing.name }
            }
            
            for unsubscribed in unsubscribedSubreddits {
                try subscribedSubredditDao.deleteSubscribedSubreddit(subredditName: unsubscribed.name ?? "", accountName: accountName)
            }
            
            subscribedSubredditDao.insertAll(
                subscribedSubredditData: subredditSubscriptions.map {
                    SubscribedSubredditData(
                        fullName: $0.name,
                        name: $0.displayName,
                        iconUrl: $0.iconImg,
                        username: accountName,
                        favorite: $0.userHasFavorited
                    )
                }
            )
            
            do {
                print(subredditSubscriptions.count)
                let count = try dbPool.read { db in
                    try SubscribedSubredditData.fetchCount(db)
                }
                print("Number of rows in SubscribedSubreddit: \(count)")
            } catch {
                print("Error fetching row count: \(error)")
            }
            
            // Handle subscribed users
            let subscribedUserDao = SubscribedUserDao(dbPool: dbPool)
            let existingUsers = try subscribedUserDao.getAllSubscribedUsersList(accountName: accountName)
            
            let unsubscribedUsers = existingUsers.filter { existing in
                !userSubscriptions.contains { $0.name == existing.name }
            }
            
            for unsubscribed in unsubscribedUsers {
                try subscribedUserDao.deleteSubscribedUser(name: unsubscribed.name, accountName: accountName)
            }
            
            subscribedUserDao.insertAll(
                subscribedUserDataList: userSubscriptions.map {
                    SubscribedUserData(
                        name: $0.displayName,
                        iconUrl: $0.iconImg,
                        username: accountName,
                        favorite: $0.userHasFavorited
                    )
                }
            )
            
            do {
                print(userSubscriptions.count)
                let count = try dbPool.read { db in
                    try SubscribedUserData.fetchCount(db)
                }
                print("Number of rows in SubscribedUserData: \(count)")
            } catch {
                print("Error fetching row count: \(error)")
            }
            
            SubredditDao(dbPool: dbPool).insertAll(subredditData: subredditSubscriptions.map {
                SubredditData(
                    id: $0.id,
                    name: $0.displayName,
                    iconUrl: $0.iconImg,
                    bannerUrl: $0.bannerBackgroundImage,
                    description: $0.description,
                    sidebarDescription: nil,
                    nSubscribers: $0.subscribers,
                    createdUTC: $0.createdUtc,
                    suggestedCommentSort: $0.suggestedCommentSort,
                    isNSFW: $0.over18
                )
            })
            
            do {
                let count = try dbPool.read { db in
                    try SubredditData.fetchCount(db)
                }
                print("Number of rows in SubredditData: \(count)")
            } catch {
                print("Error fetching row count: \(error)")
            }
        } catch {
            print("Error updating subscribed things: \(error)")
        }
    }
}
