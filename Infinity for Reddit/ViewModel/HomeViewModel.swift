//
// HomeViewModel.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-07

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var hasNewMessages: Bool = false
    private let userDefaults: UserDefaults
    
    init() {
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        self.hasNewMessages = self.userDefaults.bool(forKey: "hasNewMessages")
    }
    
    func refreshInbox() async {
        print("Foreground Refresh: Attempting to check for new data.")
        do {
            let hasNewData = try await BackgroundTasksManager.shared.checkForNewData()
            self.hasNewMessages = hasNewData
            self.userDefaults.set(hasNewData, forKey: "hasNewMessages")
            
            if hasNewData {
                print("Foreground Refresh: New data found! UI will be updated.")
                
                try await BackgroundTasksManager.shared.sendLocalNotification(
                    title: "You've got new message! (foreground)",
                    body: "Check your inbox for new messages."
                )
            } else {
                print("Foreground Refresh: No new data.")
            }
            
        } catch {
            print("Foreground Refresh: Failed to check for data. Error: \(error)")
            self.hasNewMessages = false
        }
    }
    
    func userViewedInbox() {
        print("User viewed inbox, clearing badge and updating last seen message ID.")
        self.hasNewMessages = false
        self.userDefaults.set(false, forKey: "hasNewMessages")
        
        Task {
            do {
                let inboxListingRepository = InboxListingRepository()
                let messageWhere = MessageWhere.unread
                let pathComponents: [String: String] = ["where": "\(messageWhere)"]
                let queries: [String: String] = ["limit": "50"]
                let inboxListing = try await inboxListingRepository.fetchInboxListing(
                    messageWhere: messageWhere,
                    pathComponents: pathComponents,
                    queries: queries
                )
                
                let inboxes = inboxListing.inboxes ?? []
                let createdUTCs: [TimeInterval] = inboxes.compactMap { inbox in
                    let raw = (inbox.createdUtc as Float?) 
                    guard let raw else { return nil }
                    let timeInterval = TimeInterval(raw)
                    return timeInterval > 0 ? timeInterval : nil
                }
                if let maxCreatedUTC = createdUTCs.max() {
                    self.userDefaults.set(maxCreatedUTC, forKey: "lastNotifiedUTC")
                    print("Updated lastNotifiedUTC to: \(maxCreatedUTC)")
                } else {
                    print("No unread messages; lastNotifiedUTC unchanged.")
                }
            } catch {
                print("Failed to advance lastNotifiedUTC: \(error)")
            }
        }
    }
}
