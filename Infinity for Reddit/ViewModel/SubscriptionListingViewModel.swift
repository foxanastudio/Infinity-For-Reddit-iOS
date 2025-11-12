//
//  SubscriptionListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-15.
//

import Foundation
import Combine
import GRDB
import IdentifiedCollections

public class SubscriptionListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var subredditSubscriptions: [SubscribedSubredditData] = []
    @Published var favoriteSubredditSubscriptions: [SubscribedSubredditData] = []
    @Published var userSubscriptions: [SubscribedUserData] = []
    @Published var favoriteUserSubscriptions: [SubscribedUserData] = []
    private var subscriptionsPrivate: [Subscription] = []
    @Published var myCustomFeeds: [MyCustomFeed] = []
    @Published var favoriteMyCustomFeeds: [MyCustomFeed] = []
    
    @Published var subscriptionAndCustomFeedLoadingTaskFlag: Bool = false
    @Published var isLoadingSubscriptions: Bool = false
    @Published var isLoadingMyCustomFeeds: Bool = false
    
    @Published var error: Error?
    
    private var after: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let operationqueue: OperationQueue
    private let dbPool: DatabasePool
    
    private let searchQueryPublisher = CurrentValueSubject<String, Error>("")
    private let subredditSubscriptionsPublisher: AnyPublisher<[SubscribedSubredditData], Error>
    private let userSubscriptionsPublisher: AnyPublisher<[SubscribedUserData], Error>
    private let myCustomFeedSubscriptionsPublisher: AnyPublisher<[MyCustomFeed], Error>
    private let favoriteSubredditSubscriptionsPublisher: AnyPublisher<[SubscribedSubredditData], Error>
    private let favoriteUserSubscriptionsPublisher: AnyPublisher<[SubscribedUserData], Error>
    private let favoriteMyCustomFeedSubscriptionsPublisher: AnyPublisher<[MyCustomFeed], Error>
    
    private let subscriptionListingRepository: SubscriptionListingRepositoryProtocol
    
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
        
        let subscribedSubredditDao = SubscribedSubredditDao(dbPool: dbPool)
        searchQueryPublisher.send("")
        subredditSubscriptionsPublisher = searchQueryPublisher
            .flatMap { query in
                subscribedSubredditDao.getAllSubscribedSubredditsWithSearchQuery(accountName: AccountViewModel.shared.account.username, searchQuery: query)
            }
            .eraseToAnyPublisher()
        favoriteSubredditSubscriptionsPublisher = searchQueryPublisher
            .flatMap { query in
                subscribedSubredditDao.getAllFavoriteSubscribedSubredditsWithSearchQuery(accountName: AccountViewModel.shared.account.username, searchQuery: query)
            }
            .eraseToAnyPublisher()
        
        let subscribedUserDao = SubscribedUserDao(dbPool: dbPool)
        userSubscriptionsPublisher = searchQueryPublisher
            .flatMap { query in
                subscribedUserDao.getAllSubscribedUsersWithSearchQuery(accountName: AccountViewModel.shared.account.username, searchQuery: query)
            }
            .eraseToAnyPublisher()
        favoriteUserSubscriptionsPublisher = searchQueryPublisher
            .flatMap { query in
                subscribedUserDao.getAllFavoriteSubscribedUsersWithSearchQuery(accountName: AccountViewModel.shared.account.username, searchQuery: query)
            }
            .eraseToAnyPublisher()
        
        let multiredditDao = MyCustomFeedDao(dbPool: dbPool)
        myCustomFeedSubscriptionsPublisher = searchQueryPublisher
            .flatMap { query in
                multiredditDao.getAllMyCustomFeedsWithSearchQuery(username: AccountViewModel.shared.account.username, searchQuery: query)
            }
            .eraseToAnyPublisher()
        favoriteMyCustomFeedSubscriptionsPublisher = searchQueryPublisher
            .flatMap { query in
                multiredditDao.getAllFavoriteMyCustomFeedsWithSearchQuery(username: AccountViewModel.shared.account.username, searchQuery: query)
            }
            .eraseToAnyPublisher()
        
        receiveSubscriptions()
    }
    
    // MARK: - Methods
    
    private func receiveSubscriptions() {
        subredditSubscriptionsPublisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Finished successfully.")
                    case .failure(let error):
                        print("Encountered an error: \(error)")
                    }
                },
                receiveValue: { result in
                    self.subredditSubscriptions = result
                }
            )
            .store(in: &cancellables)
        
        favoriteSubredditSubscriptionsPublisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Finished successfully.")
                    case .failure(let error):
                        print("Encountered an error: \(error)")
                    }
                },
                receiveValue: { result in
                    self.favoriteSubredditSubscriptions = result
                }
            )
            .store(in: &cancellables)
        
        userSubscriptionsPublisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Finished successfully.")
                    case .failure(let error):
                        print("Encountered an error: \(error)")
                    }
                },
                receiveValue: { result in
                    self.userSubscriptions = result
                }
            )
            .store(in: &cancellables)
        
        favoriteUserSubscriptionsPublisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Finished successfully.")
                    case .failure(let error):
                        print("Encountered an error: \(error)")
                    }
                },
                receiveValue: { result in
                    self.favoriteUserSubscriptions = result
                }
            )
            .store(in: &cancellables)
        
        myCustomFeedSubscriptionsPublisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Finished successfully.")
                    case .failure(let error):
                        print("Encountered an error: \(error)")
                    }
                },
                receiveValue: { result in
                    self.myCustomFeeds = result
                }
            )
            .store(in: &cancellables)
        
        favoriteMyCustomFeedSubscriptionsPublisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Finished successfully.")
                    case .failure(let error):
                        print("Encountered an error: \(error)")
                    }
                },
                receiveValue: { result in
                    self.favoriteMyCustomFeeds = result
                }
            )
            .store(in: &cancellables)
    }
    
    public func setSearchQuery(_ query: String) {
        searchQueryPublisher.send(query)
    }
    
    public func loadSubscriptionsOnline(forceLoad: Bool = false) async {
        guard forceLoad || Int64(Date().timeIntervalSince1970) - AccountViewModel.shared.account.subscriptionSyncTime >= 60 * 60 * 24 else {
            return
        }
        
        guard !isLoadingSubscriptions || forceLoad else {
            return
        }
        
        await MainActor.run {
            isLoadingSubscriptions = true
        }
        
        do {
            try Task.checkCancellation()
            
            let subscriptionListing = try await subscriptionListingRepository.fetchSubscriptions(
                queries: ["limit": "100", "after": after ?? ""]
            )
            
            if (subscriptionListing.subscriptions.isEmpty) {
                // No more subscriptions
                try Task.checkCancellation()
                
                await transformSubsriptions()
                
                do {
                    try await AccountViewModel.shared.updateSubscriptionSyncTime()
                } catch {
                    print("Unable to update subscription sync time: \(error)")
                }
            } else {
                try Task.checkCancellation()
                
                await MainActor.run {
                    self.after = subscriptionListing.after
                }
                
                subscriptionsPrivate.append(contentsOf: subscriptionListing.subscriptions)
                
                if self.after == nil || self.after?.isEmpty == true {
                    try Task.checkCancellation()
                    
                    await transformSubsriptions()
                    
                    do {
                        try await AccountViewModel.shared.updateSubscriptionSyncTime()
                    } catch {
                        print("Unable to update subscription sync time: \(error)")
                    }
                } else {
                    await loadSubscriptionsOnline(forceLoad: true)
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.after = nil
                self.isLoadingSubscriptions = false
                
                print("Error fetching subscriptions: \(error)")
            }
        }
    }
    
    private func transformSubsriptions() async {
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
        
        let subredditSubscriptionsTemp = subreddits.map {
            SubscribedSubredditData(
                fullName: $0.name,
                name: $0.displayName,
                iconUrl: $0.iconImg == nil || $0.iconImg.isEmpty ? $0.communityIcon : $0.iconImg,
                username: AccountViewModel.shared.account.username,
                isFavorite: $0.userHasFavorited
            )
        }
        
        let userSubscriptionsTemp = users.map {
            SubscribedUserData(
                name: $0.displayName,
                iconUrl: $0.iconImg == nil || $0.iconImg.isEmpty ? $0.communityIcon : $0.iconImg,
                username: AccountViewModel.shared.account.username,
                isFavorite: $0.userHasFavorited
            )
        }
        
        insertSubscribedThings(subredditSubscriptions: subredditSubscriptionsTemp, userSubscriptions: userSubscriptionsTemp, subreddits: subreddits.map {
            SubredditData(
                id: $0.id,
                name: $0.displayName,
                fullName: $0.name,
                iconUrl: $0.iconImg == nil || $0.iconImg.isEmpty ? $0.communityIcon : $0.iconImg,
                bannerUrl: $0.bannerBackgroundImage,
                description: $0.description,
                sidebarDescription: nil,
                nSubscribers: $0.subscribers,
                createdUTC: $0.createdUtc,
                suggestedCommentSort: $0.suggestedCommentSort,
                isNSFW: $0.over18
            )
        })
        
        await MainActor.run {
            self.after = nil
            self.isLoadingSubscriptions = false
            self.subredditSubscriptions = subredditSubscriptionsTemp
            self.userSubscriptions = userSubscriptionsTemp
        }
    }
    
    public func loadMyCustomFeedsOnline() async {
        guard Int64(Date().timeIntervalSince1970) - AccountViewModel.shared.account.customFeedSyncTime >= 60 * 60 * 24 else { return }
        
        guard !isLoadingMyCustomFeeds else { return }
        
        await MainActor.run {
            isLoadingMyCustomFeeds = true
        }
        
        do {
            try Task.checkCancellation()
            
            let myCustomFeedListing = try await subscriptionListingRepository.fetchMyCustomFeeds()
            
            try Task.checkCancellation()
            
            myCustomFeedListing.customFeeds.sort { $0.displayName < $1.displayName }
            
            let myCustomFeedsTemp = myCustomFeedListing.customFeeds.map {
                MyCustomFeed(
                    path: $0.path,
                    displayName: $0.displayName,
                    name: $0.name,
                    description: $0.descriptionMd,
                    copiedFrom: $0.copiedFrom,
                    iconUrl: $0.iconUrl,
                    visibility: $0.visibility,
                    owner: $0.owner,
                    nSubscribers: $0.numSubscribers,
                    createdUTC: Int64($0.createdUtc),
                    over18: $0.over18,
                    isSubscriber: $0.isSubscriber,
                    isFavorite: $0.isFavorited
                )
            }
            
            try Task.checkCancellation()
            
            insertMyCustomFeeds(myCustomFeeds: myCustomFeedsTemp)
            
            do {
                try await AccountViewModel.shared.updateCustomFeedSyncTime()
            } catch {
                print("Unable to update custom feed sync time: \(error)")
            }
            
            await MainActor.run {
                self.isLoadingMyCustomFeeds = false
                self.myCustomFeeds = myCustomFeedsTemp
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoadingMyCustomFeeds = false
            }
            
            print("Error fetching custom feeds: \(error)")
        }
    }
    
    func refreshSubscriptions() {
        isLoadingSubscriptions = false
        isLoadingMyCustomFeeds = false
        
        after = nil
        subscriptionsPrivate = []
        
        AccountViewModel.shared.account.subscriptionSyncTime = 0
        AccountViewModel.shared.account.customFeedSyncTime = 0
        subscriptionAndCustomFeedLoadingTaskFlag.toggle()
    }
    
    private func insertSubscribedThings(subredditSubscriptions: [SubscribedSubredditData], userSubscriptions: [SubscribedUserData], subreddits: [SubredditData]) {
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
                try subscribedSubredditDao.deleteSubscribedSubreddit(subredditName: unsubscribed.name, accountName: accountName)
            }
            
            subscribedSubredditDao.insertAll(
                subscribedSubredditData: subredditSubscriptions
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
                subscribedUserDataList: userSubscriptions
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
            
            try SubredditDao(dbPool: dbPool).insertAll(subredditData: subreddits)
            
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
    
    private func insertMyCustomFeeds(myCustomFeeds: [MyCustomFeed]) {
        do {
            // Check if account exists
            guard !AccountViewModel.shared.account.isAnonymous(),
                  let _ = try AccountDao(dbPool: dbPool).getAccount(username: AccountViewModel.shared.account.username) else {
                return
            }
            
            let myCustomFeedDao = MyCustomFeedDao(dbPool: dbPool)
            let existingMyCustomFeeds = try myCustomFeedDao.getAllMyCustomFeedsList(username: AccountViewModel.shared.account.username)
            
            let unsubscribedMyCustomFeeds = existingMyCustomFeeds.filter { existing in
                !myCustomFeeds.contains { $0.path == existing.path }
            }
            
            for unsubscribed in unsubscribedMyCustomFeeds {
                try myCustomFeedDao.deleteMyCustomFeed(name: unsubscribed.name, username: AccountViewModel.shared.account.username)
            }
            
            myCustomFeedDao.insertAll(
                myCustomFeeds: myCustomFeeds
            )
            
            do {
                print(myCustomFeeds.count)
                let count = try dbPool.read { db in
                    try MyCustomFeed.fetchCount(db)
                }
                print("Number of rows in MyCustomFeed: \(count)")
            } catch {
                print("Error fetching row count: \(error)")
            }
        } catch {
            print("Error updating my custom feeds: \(error)")
        }
    }
    
    func toggleFavoriteSubreddit(_ subscribedSubreddit: SubscribedSubredditData) async {
        do {
            try await subscriptionListingRepository.toggleFavoriteSubreddit(subscribedSubreddit)
        } catch {
            // TODO handle error
            print("Toggle favorite subreddit error: \(error)")
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func toggleFavoriteUser(_ subscribedUser: SubscribedUserData) async {
        do {
            try await subscriptionListingRepository.toggleFavoriteUser(subscribedUser)
        } catch {
            // TODO handle error
            print("Toggle favorite user error: \(error)")
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func toggleFavoriteCustomFeed(_ myCustomFeed: MyCustomFeed) async {
        do {
            try await subscriptionListingRepository.toggleFavoriteCustomFeed(myCustomFeed)
        } catch {
            // TODO handle error
            print("Toggle favorite custom feed error: \(error)")
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func unsubscribeFromSubreddit(_ subscribedSubreddit: SubscribedSubredditData) async {
        do {
            try await subscriptionListingRepository.unsubscribeFromSubreddit(subscribedSubreddit)
        } catch {
            print("Unsubscribe from subreddit error: \(error)")
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func unfollowUser(_ subscribedUser: SubscribedUserData) async {
        do {
            try await subscriptionListingRepository.unfollowUser(subscribedUser)
        } catch {
            print("Unfollow user error: \(error)")
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func deleteCustomFeed(_ myCustomFeed: MyCustomFeed) async {
        do {
            try await subscriptionListingRepository.deleteCustomFeed(myCustomFeed)
        } catch {
            print("Delete custom feed error: \(error)")
            await MainActor.run {
                self.error = error
            }
        }
    }
}
