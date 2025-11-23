//
//  SearchViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-18.
//

import Foundation
import Combine
import GRDB

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var searchInThing: Thing?
    @Published var recentSearchQueries: [RecentSearchQuery] = []
    
    var searchInSubredditOrUserName: String {
        if let searchInThing = searchInThing {
            return searchInThing.searchInSubredditOrUserName
        } else {
            return ""
        }
    }
    
    var searchInCustomFeed: String {
        if let searchInThing = searchInThing {
            return searchInThing.searchInCustomFeed
        } else {
            return ""
        }
    }
    
    var searchInCustomFeedDisplayName: String {
        if let searchInThing = searchInThing {
            return searchInThing.displayName
        } else {
            return ""
        }
    }
    
    var searchInThingType: SearchInThingType {
        if let searchInThing = searchInThing {
            return searchInThing.searchInThingType
        } else {
            return .all
        }
    }
    
    private let dbPool: DatabasePool
    private let searchRepository: SearchRepository
    
    private let username: String
    private let recentSearchQueriesPublisher: AnyPublisher<[RecentSearchQuery], Error>
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        guard let resolvedOperationQueue = DependencyManager.shared.container.resolve(OperationQueue.self) else {
            fatalError("Could not resolve OperationQueue")
        }
        
        guard let resolvedDatabasePool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Could not resolve DatabasePool")
        }
        
        self.username = AccountViewModel.shared.account.username
        self.dbPool = resolvedDatabasePool
        
        let recentSearchQueryDao = RecentSearchQueryDao(dbPool: dbPool)
        self.searchRepository = SearchRepository(recentSearchQueryDao: recentSearchQueryDao, operationQueue: resolvedOperationQueue)
        recentSearchQueriesPublisher = recentSearchQueryDao.getAllRecentSearchQueriesLiveData(username: username)
        
        receiveRecentSearchQueries()
    }
    
    private func receiveRecentSearchQueries() {
        recentSearchQueriesPublisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished successfully.")
                case .failure(let error):
                    print("Encountered an error: \(error)")
                }
            },
            receiveValue: { result in
                self.recentSearchQueries = result
            }
        )
        .store(in: &cancellables)
    }
    
    func saveSearchQuery() {
        searchRepository.saveSearchQuery(
            username: username,
            query: query,
            searchInSubredditOrUserName: searchInSubredditOrUserName,
            customFeedPath: searchInCustomFeed,
            customFeedDisplayName: searchInCustomFeedDisplayName,
            searchInThingType: searchInThingType,
            time: Int64(Date().timeIntervalSince1970)
        )
    }
    
    func clearAllRecentSearchQueries() {
        searchRepository.clearAllRecentSearchQueries(username: username)
    }
    
    func deleteSearchQuery(recentSearchQuery: RecentSearchQuery) {
        searchRepository.deleteRecentSearchQueries(recentSearchQuery: recentSearchQuery)
    }
}
