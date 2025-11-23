//
//  AnonymousSubscriptionListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-08.
//

import Foundation
import Combine
import GRDB
import IdentifiedCollections

public class AnonymousSubscriptionListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var subredditSubscriptions: [SubscribedSubredditData] = []
    @Published var favoriteSubredditSubscriptions: [SubscribedSubredditData] = []
    @Published var userSubscriptions: [SubscribedUserData] = []
    @Published var favoriteUserSubscriptions: [SubscribedUserData] = []
    @Published var myCustomFeeds: [MyCustomFeed] = []
    @Published var favoriteMyCustomFeeds: [MyCustomFeed] = []
    
    @Published var selectedSubscribedSubreddits: IdentifiedArrayOf<SubscribedSubredditData> = []
    @Published var selectedSubreddits: IdentifiedArrayOf<SubredditData> = []
    @Published var selectedSubredditsInCustomFeed: IdentifiedArrayOf<SubredditInCustomFeed> = []
    @Published var selectedSubscribedUsers: IdentifiedArrayOf<SubscribedUserData> = []
    @Published var selectedUsers: IdentifiedArrayOf<UserData> = []
    
    @Published var error: Error?
    
    let subscriptionSelectionMode: ThingSelectionMode
    private let anonymousSubscriptionListingRepository: AnonymousSubscriptionListingRepositoryProtocol
    
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
    
    // MARK: - Initializer
    init(subscriptionSelectionMode: ThingSelectionMode, anonymousSubscriptionListingRepository: AnonymousSubscriptionListingRepositoryProtocol) {
        guard let resolvedOperationQueue = DependencyManager.shared.container.resolve(OperationQueue.self) else {
            fatalError("Could not resolve OperationQueue")
        }
        
        guard let resolvedDatabasePool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Could not resolve DatabasePool")
        }
        
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
                case .myCustomFeed(_):
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
        self.anonymousSubscriptionListingRepository = anonymousSubscriptionListingRepository
        self.operationqueue = resolvedOperationQueue
        self.dbPool = resolvedDatabasePool
        
        let subscribedSubredditDao = SubscribedSubredditDao(dbPool: dbPool)
        searchQueryPublisher.send("")
        subredditSubscriptionsPublisher = searchQueryPublisher
            .flatMap { query in
                subscribedSubredditDao.getAllSubscribedSubredditsWithSearchQuery(accountName: Account.ANONYMOUS_ACCOUNT.username, searchQuery: query)
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
                subscribedUserDao.getAllSubscribedUsersWithSearchQuery(accountName: Account.ANONYMOUS_ACCOUNT.username, searchQuery: query)
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
                multiredditDao.getAllMyCustomFeedsWithSearchQuery(username: Account.ANONYMOUS_ACCOUNT.username, searchQuery: query)
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
    
    func toggleFavoriteSubreddit(_ subscribedSubreddit: SubscribedSubredditData) {
        if !anonymousSubscriptionListingRepository.toggleFavoriteSubreddit(subscribedSubreddit) {
            // TODO handle error
        }
    }
    
    func toggleFavoriteUser(_ subscribedUser: SubscribedUserData) {
        if !anonymousSubscriptionListingRepository.toggleFavoriteUser(subscribedUser) {
            // TODO handle error
        }
    }
    
    func toggleFavoriteCustomFeed(_ myCustomFeed: MyCustomFeed) {
        if !anonymousSubscriptionListingRepository.toggleFavoriteCustomFeed(myCustomFeed) {
            // TODO handle error
        }
    }
    
    func unsubscribeFromSubreddit(_ subscribedSubreddit: SubscribedSubredditData) async {
        do {
            try await anonymousSubscriptionListingRepository.unsubscribeFromSubreddit(subscribedSubreddit)
        } catch {
            print("Unsubscribe from subreddit error: \(error)")
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func unfollowUser(_ subscribedUser: SubscribedUserData) async {
        do {
            try await anonymousSubscriptionListingRepository.unfollowUser(subscribedUser)
        } catch {
            print("Unfollow user error: \(error)")
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func deleteCustomFeed(_ myCustomFeed: MyCustomFeed) async {
        do {
            try await anonymousSubscriptionListingRepository.deleteCustomFeed(myCustomFeed)
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
}
