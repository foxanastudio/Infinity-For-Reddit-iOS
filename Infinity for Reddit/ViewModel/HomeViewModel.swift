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
    @Published var pendingInboxRoute: InboxRoute?
    
    struct InboxRoute: Equatable {
        let viewMessage: Bool
    }
    
    private let userDefaults: UserDefaults
    
    init() {
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
    }
    
    func refreshInbox() async {
        print("Foreground Refresh: Pull & notify via unified pipeline.")
        let anySent = await BackgroundTasksManager.shared.refreshAndNotifyAllAccounts()
        if hasNewMessages != anySent { hasNewMessages = anySent}
        print(anySent ? "Foreground Refresh: New message found! UI will be updated."
              : "Foreground Refresh: No new message.")
    }
    
    func userViewedInbox() {
        print("User viewed inbox, clearing badge and advancing last seen.")
        hasNewMessages = false
    }
}
