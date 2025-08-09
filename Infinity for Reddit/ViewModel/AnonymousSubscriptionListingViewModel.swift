//
//  AnonymousSubscriptionListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-08.
//

import Foundation
import Combine
import GRDB

public class AnonymousSubscriptionListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var subredditSubscriptions: [SubscribedSubredditData] = []
    @Published var userSubscriptions: [SubscribedUserData] = []
    @Published var myCustomFeeds: [MyCustomFeed] = []
    
    private let anonymousSubscriptionListingRepository: AnonymousSubscriptionListingRepositoryProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private let operationqueue: OperationQueue
    private let dbPool: DatabasePool
    
    private let searchQueryPublisher = CurrentValueSubject<String, Error>("")
    private let subredditSubscriptionsPublisher: AnyPublisher<[SubscribedSubredditData], Error>
    private let userSubscriptionsPublisher: AnyPublisher<[SubscribedUserData], Error>
    private let myCustomFeedSubscriptionsPublisher: AnyPublisher<[MyCustomFeed], Error>
    
    // MARK: - Initializer
    init(anonymousSubscriptionListingRepository: AnonymousSubscriptionListingRepositoryProtocol) {
        guard let resolvedOperationQueue = DependencyManager.shared.container.resolve(OperationQueue.self) else {
            fatalError("Could not resolve OperationQueue")
        }
        
        guard let resolvedDatabasePool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Could not resolve DatabasePool")
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
        
        let subscribedUserDao = SubscribedUserDao(dbPool: dbPool)
        userSubscriptionsPublisher = searchQueryPublisher
            .flatMap { query in
                subscribedUserDao.getAllSubscribedUsersWithSearchQuery(accountName: Account.ANONYMOUS_ACCOUNT.username, searchQuery: query)
            }
            .eraseToAnyPublisher()
        
        let multiredditDao = MyCustomFeedDao(dbPool: dbPool)
        myCustomFeedSubscriptionsPublisher = searchQueryPublisher
            .flatMap { query in
                multiredditDao.getAllMyCustomFeedsWithSearchQuery(username: Account.ANONYMOUS_ACCOUNT.username, searchQuery: query)
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
}
