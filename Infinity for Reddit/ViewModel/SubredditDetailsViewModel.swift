//
// SubredditDetailsViewModel.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-05-02

import Foundation
import GRDB
import Combine
import Swinject
import Alamofire
import SwiftUI
import SwiftyJSON

@MainActor
class SubredditDetailsViewModel: ObservableObject {
    @Published var subredditName: String
    @Published var subredditData: SubredditData?
    @Published var isSubscribed: Bool = false
    @Published var error: Error?
    
    private let session: Session
    private let dbPool: DatabasePool
    
    public let subredditDetailsRepository: SubredditDetailsRepositoryProtocol
    
    // MARK: - Initializer
    init(subredditName: String, subredditDetailsRepository: SubredditDetailsRepositoryProtocol) {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError( "Failed to resolve DatabasePool")
        }
        self.session = resolvedSession
        self.dbPool = resolvedDBPool
        self.subredditName = subredditName
        self.subredditDetailsRepository = subredditDetailsRepository
        
    }
    
    // MARK: - Methods
    func toggleSubscribeSubreddit() async {
        await subscribeSubreddit(action: isSubscribed ? "unsub" : "sub")
    }
    
    private func subscribeSubreddit(action: String) async {
        do {
            try Task.checkCancellation()
            
            if !AccountViewModel.shared.account.isAnonymous() {
                try await subredditDetailsRepository.subsribeSubreddit(subredditName: subredditName, action: action)
            }
            
            try Task.checkCancellation()
            
            let subscribedSubredditDao = SubscribedSubredditDao(dbPool: dbPool)
            if action == "unsub" {
                try subscribedSubredditDao.deleteSubscribedSubreddit(subredditName: subredditName, accountName: AccountViewModel.shared.account.username)
            } else {
                if let subredditData = self.subredditData {
                    let subscribedSubredditData = SubscribedSubredditData(
                        fullName: subredditData.fullName,
                        name: subredditName,
                        iconUrl: subredditData.iconUrl,
                        username: AccountViewModel.shared.account.username,
                        isFavorite: false
                    )
                    try subscribedSubredditDao.insert(subscribedSubredditData: subscribedSubredditData)
                }
            }
            
            self.isSubscribed = action == "sub"
        } catch {
            self.error = error
            
            print("Error \(action == "sub" ? "subscribing to" : "unsubscribing from") \(subredditName): \(error)")
        }
    }
    
    func fetchSubredditDetails() async {
        do {
            try Task.checkCancellation()
            
            let fetchData = try await subredditDetailsRepository.fetchSubredditDetails(subredditName: subredditName)
            
            try Task.checkCancellation()
            
            self.subredditData = fetchData
            
            let subscribedSubredditDao = SubscribedSubredditDao(dbPool: dbPool)
            let isSubscribedReddit = try subscribedSubredditDao.getSubscribedSubreddit(subredditName: fetchData.name, accountName: AccountViewModel.shared.account.username) != nil
            self.isSubscribed = isSubscribedReddit
            
            do {
                let subredditDao = SubredditDao(dbPool: dbPool)
                try subredditDao.insert(subredditData: fetchData)
            } catch {
                print("Error: Failed to insert subredditData - \(error.localizedDescription)")
            }
            
        } catch {
            self.error = error
            
            print("Error fetching user data: \(error)")
        }
    }
}
