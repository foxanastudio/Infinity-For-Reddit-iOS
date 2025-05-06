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

class SubredditDetailsViewModel: ObservableObject {
    private let session: Session
    
    @Published var subredditName: String
    @Published var subredditData: SubredditData?
    @Published var isSubscribed: Bool = false
    @Published var error: Error?
    
    public let subredditDetailsRepository: SubredditDetailsRepositoryProtocol
    
    // MARK: - Initializer
    init(subredditName: String, subredditDetailsRepository: SubredditDetailsRepositoryProtocol) {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
        self.subredditName = subredditName
        self.subredditDetailsRepository = subredditDetailsRepository
        
    }
    
    // MARK: - Methods
    func toggleSubscribeSubreddit() async {
        await subscribeSubreddit(subredditName: subredditName, action: isSubscribed ? "unsub" : "sub")
    }
    
    private func subscribeSubreddit(subredditName: String, action: String) async {
        do {
            try await subredditDetailsRepository.subsribeSubreddit(subredditName: subredditName, action: action)
            self.isSubscribed = action == "sub"
        } catch {
            self.error = error
            print("Error \(action == "sub" ? "following to" : "unfollowing from") \(subredditName): \(error)")
        }
    }
    
    func formattedCakeDay(_ timestamp: TimeInterval?) -> String {
        guard let timestamp = timestamp else {
            return "Unknown"
        }
        
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: date)
    }
    
    func fetchSubredditDetails() async {
        do {
            try Task.checkCancellation()
            
            let fetchData = try await subredditDetailsRepository.fetchSubredditDetails(subredditName: subredditName)
            
            try Task.checkCancellation()
             
            await MainActor.run {
                self.subredditData = fetchData
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
            print("Error fetching user data: \(error)")
        }
    }
}
