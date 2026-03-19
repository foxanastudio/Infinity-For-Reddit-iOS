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
    @Published var userFlairs: [UserFlair]?
    @Published var showSensitiveSubredditWarningTrigger: Bool = false
    @Published var error: Error?
    
    private let subredditDetailsRepository: SubredditDetailsRepositoryProtocol
    private var subscribeSubredditTask: Task<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(subredditName: String, subredditDetailsRepository: SubredditDetailsRepositoryProtocol) {
        self.subredditName = subredditName
        self.subredditDetailsRepository = subredditDetailsRepository
        
        NotificationCenter.default.publisher(for: Notification.Name.accountAllowSensitiveChanged)
            .sink { [weak self] notification in
                guard let self, let subredditData else {
                    return
                }
                self.showSensitiveSubredditWarningTrigger = subredditData.isSensitive && !AccountAllowSensitiveNotification.isAllowSensitive(notification)
            }
            .store(in: &cancellables)
    }
    
    func fetchSubredditDetails() async {
        do {
            try Task.checkCancellation()
            
            let subredditData = try await subredditDetailsRepository.fetchSubredditDetails(subredditName: subredditName)
            
            try Task.checkCancellation()
            
            self.subredditData = subredditData
            self.showSensitiveSubredditWarningTrigger = subredditData.isSensitive && !AccountViewModel.shared.account.allowSensitive
        } catch {
            self.error = error
            
            printInDebugOnly("Error fetching subreddit data: \(error)")
        }
    }
    
    func toggleSubscribeSubreddit() {
        guard let subredditData else {
            return
        }
        
        subscribeSubredditTask?.cancel()
        subscribeSubredditTask = Task {
            let action = subredditData.isSubscribed ? "unsub" : "sub"
            do {
                try await subredditDetailsRepository.subsribeSubreddit(subredditData: subredditData, action: action)
                
                try Task.checkCancellation()
                
                self.subredditData?.isSubscribed = action == "sub"
            } catch {
                self.error = error
                
                printInDebugOnly("Error \(action == "sub" ? "subscribing to" : "unsubscribing from") \(subredditName): \(error)")
            }
        }
    }
    
    func fetchUserFlairs() {
        guard userFlairs == nil else {
            return
        }
        
        Task {
            do {
                self.userFlairs = try await subredditDetailsRepository.fetchUserFlairs(subredditName: subredditName)
            } catch {
                self.error = error
                printInDebugOnly(error)
            }
        }
    }
    
    func selectUserFlair(_ userFlair: UserFlair) {
        Task {
            do {
                try await subredditDetailsRepository.selectUserFlair(subredditName: subredditName, userFlair: userFlair)
            } catch {
                self.error = error
                printInDebugOnly(error)
            }
        }
    }
    
    func cleaarUserFlair() {
        Task {
            do {
                try await subredditDetailsRepository.selectUserFlair(subredditName: subredditName, userFlair: nil)
            } catch {
                self.error = error
                printInDebugOnly(error)
            }
        }
    }
}
