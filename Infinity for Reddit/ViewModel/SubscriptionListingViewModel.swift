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
    @Published var subredditSubscriptions: [SubscribedSubredditData] = []
    @Published var favoriteSubredditSubscriptions: [SubscribedSubredditData] = []
    @Published var userSubscriptions: [SubscribedUserData] = []
    @Published var favoriteUserSubscriptions: [SubscribedUserData] = []
    private var subscriptionsPrivate: [Subscription] = []
    @Published var myCustomFeeds: [MyCustomFeed] = []
    @Published var favoriteMyCustomFeeds: [MyCustomFeed] = []
    
    @Published var selectedSubscribedSubreddits: IdentifiedArrayOf<SubscribedSubredditData> = []
    @Published var selectedSubreddits: IdentifiedArrayOf<SubredditData> = []
    @Published var selectedSubredditsInCustomFeed: IdentifiedArrayOf<SubredditInCustomFeed> = []
    @Published var selectedSubscribedUsers: IdentifiedArrayOf<SubscribedUserData> = []
    @Published var selectedUsers: IdentifiedArrayOf<UserData> = []
    @Published var selectedMyCustomFeeds: IdentifiedArrayOf<MyCustomFeed> = []
    
    @Published var subscriptionAndCustomFeedLoadingTaskFlag: Bool = false
    @Published var isLoadingSubscriptions: Bool = false
    @Published var isLoadingMyCustomFeeds: Bool = false
    
    @Published var error: Error?
    
    private var after: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let operationqueue: OperationQueue
    private let dbPool: DatabasePool
    private let refreshInterval = 60 * 60 * 24
    
    private let searchQueryPublisher = CurrentValueSubject<String, Error>("")
    private let subredditSubscriptionsPublisher: AnyPublisher<[SubscribedSubredditData], Error>
    private let userSubscriptionsPublisher: AnyPublisher<[SubscribedUserData], Error>
    private let myCustomFeedSubscriptionsPublisher: AnyPublisher<[MyCustomFeed], Error>
    private let favoriteSubredditSubscriptionsPublisher: AnyPublisher<[SubscribedSubredditData], Error>
    private let favoriteUserSubscriptionsPublisher: AnyPublisher<[SubscribedUserData], Error>
    private let favoriteMyCustomFeedSubscriptionsPublisher: AnyPublisher<[MyCustomFeed], Error>
    
    let subscriptionSelectionMode: ThingSelectionMode
    private let subscriptionListingRepository: SubscriptionListingRepositoryProtocol
    
    // MARK: - Initializer
    init(subscriptionSelectionMode: ThingSelectionMode, subscriptionListingRepository: SubscriptionListingRepositoryProtocol) {
        self.subscriptionSelectionMode = subscriptionSelectionMode
        switch subscriptionSelectionMode {
        case .subredditAndUserMultiSelection(let selectedSubredditsAndUsers, _):
            var selectedSubscribedSubreddits = IdentifiedArrayOf<SubscribedSubredditData>()
            var selectedSubreddits = IdentifiedArrayOf<SubredditData>()
            var selectedSubredditsInCustomFeed = IdentifiedArrayOf<SubredditInCustomFeed>()
            var selectedSubscribedUsers = IdentifiedArrayOf<SubscribedUserData>()
            var selectedUsers = IdentifiedArrayOf<UserData>()
            
            for item in selectedSubredditsAndUsers {
                switch item {
                case .subscribedSubreddit(let subscribedSubredditData):
                    selectedSubscribedSubreddits.append(subscribedSubredditData)
                case .subreddit(let subredditData):
                    selectedSubreddits.append(subredditData)
                case .subredditInCustomFeed(let subredditInCustomFeed):
                    selectedSubredditsInCustomFeed.append(subredditInCustomFeed)
                case .subredditInAnonymousCustomFeed(let anonymousCustomFeedSubreddit):
                    selectedSubredditsInCustomFeed.append(SubredditInCustomFeed(name: anonymousCustomFeedSubreddit.subredditName))
                case .subscribedUser(let subscribedUserData):
                    selectedSubscribedUsers.append(subscribedUserData)
                case .user(let userData):
                    selectedUsers.append(userData)
                case .myCustomFeed:
                    break
                }
            }
            
            self.selectedSubscribedSubreddits = selectedSubscribedSubreddits
            self.selectedSubreddits = selectedSubreddits
            self.selectedSubredditsInCustomFeed = selectedSubredditsInCustomFeed
            self.selectedSubscribedUsers = selectedSubscribedUsers
            self.selectedUsers = selectedUsers
        default:
            break
        }
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
                receiveValue: { [weak self] result in
                    guard let self else {
                        return
                    }
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
                receiveValue: { [weak self] result in
                    guard let self else {
                        return
                    }
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
                receiveValue: { [weak self] result in
                    guard let self else {
                        return
                    }
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
                receiveValue: { [weak self] result in
                    guard let self else {
                        return
                    }
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
                receiveValue: { [weak self] result in
                    guard let self else {
                        return
                    }
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
                receiveValue: { [weak self] result in
                    guard let self else {
                        return
                    }
                    self.favoriteMyCustomFeeds = result
                }
            )
            .store(in: &cancellables)
    }
    
    public func setSearchQuery(_ query: String) {
        searchQueryPublisher.send(query)
    }
    
    public func loadSubscriptionsOnline(isPagination: Bool = false) async {
        guard isPagination || Int64(Date().timeIntervalSince1970) - AccountViewModel.shared.account.subscriptionSyncTime >= refreshInterval else {
            return
        }
        
        guard !isLoadingSubscriptions || isPagination else {
            return
        }
        
        if !isPagination {
            // Start over
            subscriptionsPrivate = []
            after = nil
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
                    await loadSubscriptionsOnline(isPagination: true)
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
        
        await insertSubscribedThings(subredditSubscriptions: subredditSubscriptionsTemp, userSubscriptions: userSubscriptionsTemp, subreddits: subreddits.map {
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
            self.subscriptionsPrivate = []
            self.isLoadingSubscriptions = false
        }
    }
    
    public func loadMyCustomFeedsOnline() async {
        guard Int64(Date().timeIntervalSince1970) - AccountViewModel.shared.account.customFeedSyncTime >= refreshInterval else { return }
        
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
                $0.toMyCustomFeed()
            }
            
            try Task.checkCancellation()
            
            await insertMyCustomFeeds(myCustomFeeds: myCustomFeedsTemp)
            
            do {
                try await AccountViewModel.shared.updateCustomFeedSyncTime()
            } catch {
                print("Unable to update custom feed sync time: \(error)")
            }
            
            await MainActor.run {
                self.isLoadingMyCustomFeeds = false
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
        
        AccountViewModel.shared.account.subscriptionSyncTime = 0
        AccountViewModel.shared.account.customFeedSyncTime = 0
        subscriptionAndCustomFeedLoadingTaskFlag.toggle()
    }
    
    private func insertSubscribedThings(subredditSubscriptions: [SubscribedSubredditData], userSubscriptions: [SubscribedUserData], subreddits: [SubredditData]) async {
        do {
            // Check if account exists
            guard !AccountViewModel.shared.account.isAnonymous(),
                  let _ = try AccountDao(dbPool: dbPool).getAccount(username: AccountViewModel.shared.account.username) else {
                return
            }
            
            let accountName = AccountViewModel.shared.account.username
            
            // Handle subscribed subreddits
            let subscribedSubredditDao = SubscribedSubredditDao(dbPool: dbPool)
            let existingSubreddits = try await subscribedSubredditDao.getAllSubscribedSubredditsList(accountName: accountName)
            
            let unsubscribedSubreddits = existingSubreddits.filter { existing in
                !subredditSubscriptions.contains { $0.name == existing.name }
            }
            
            for unsubscribed in unsubscribedSubreddits {
                try? await subscribedSubredditDao.deleteSubscribedSubreddit(subredditName: unsubscribed.name, accountName: accountName)
            }
            
            try? await subscribedSubredditDao.insertAll(
                subscribedSubredditData: subredditSubscriptions
            )
            
            // Handle subscribed users
            let subscribedUserDao = SubscribedUserDao(dbPool: dbPool)
            let existingUsers = try await subscribedUserDao.getAllSubscribedUsersList(accountName: accountName)
            
            let unsubscribedUsers = existingUsers.filter { existing in
                !userSubscriptions.contains { $0.name == existing.name }
            }
            
            for unsubscribed in unsubscribedUsers {
                try? await subscribedUserDao.deleteSubscribedUser(name: unsubscribed.name, accountName: accountName)
            }
            
            try? await subscribedUserDao.insertAll(
                subscribedUserDataList: userSubscriptions
            )
            
            try await SubredditDao(dbPool: dbPool).insertAll(subredditData: subreddits)
        } catch {
            print("Error updating subscribed things: \(error)")
        }
    }
    
    private func insertMyCustomFeeds(myCustomFeeds: [MyCustomFeed]) async {
        do {
            // Check if account exists
            guard !AccountViewModel.shared.account.isAnonymous(),
                  let _ = try AccountDao(dbPool: dbPool).getAccount(username: AccountViewModel.shared.account.username) else {
                return
            }
            
            let myCustomFeedDao = MyCustomFeedDao(dbPool: dbPool)
            let existingMyCustomFeeds = try await myCustomFeedDao.getAllMyCustomFeedsList(username: AccountViewModel.shared.account.username)
            
            let unsubscribedMyCustomFeeds = existingMyCustomFeeds.filter { existing in
                !myCustomFeeds.contains { $0.path == existing.path }
            }
            
            for unsubscribed in unsubscribedMyCustomFeeds {
                try? await myCustomFeedDao.deleteMyCustomFeed(path: unsubscribed.path, username: AccountViewModel.shared.account.username)
            }
            
            try await myCustomFeedDao.insertAll(
                myCustomFeeds: myCustomFeeds
            )
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
    
    func getSelectedSubredditsAndUsers() -> [Thing] {
        var result: [Thing] = []
        
        for subscribedSubredditData in selectedSubscribedSubreddits {
            result.append(.subscribedSubreddit(subscribedSubredditData))
        }
        for subscribedUserData in selectedSubscribedUsers {
            result.append(.subscribedUser(subscribedUserData))
        }
        
        return result
    }
    
    func getSelectedSubreddits() -> [Thing] {
        var result: [Thing] = []
        
        for subscribedSubredditData in selectedSubscribedSubreddits {
            result.append(.subscribedSubreddit(subscribedSubredditData))
        }
        
        return result
    }
    
    func getSelectedUsers() -> [Thing] {
        var result: [Thing] = []
        
        for subscribedUserData in selectedSubscribedUsers {
            result.append(.subscribedUser(subscribedUserData))
        }
        
        return result
    }
    
    func getSelectedMyCustomFeeds() -> [Thing] {
        var result: [Thing] = []
        
        for myCustomFeed in selectedMyCustomFeeds {
            result.append(.myCustomFeed(myCustomFeed))
        }
        
        return result
    }
}
