//
// HomeViewModel.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-07

import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var hasNewMessages: Bool = false
    @Published var inboxNavigationTarget: InboxNavigationTarget?
    @Published var inboxCount: Int = 0
    
    private let homeRepository: HomeRepositoryProtocol
    private var inboxCountPollingTask: Task<Void, Never>?
    private var hasFetchedInboxCount: Bool = false
    private var lastInboxCountPollingTime: TimeInterval = 0
    
    struct InboxNavigationTarget: Equatable {
        let viewMessage: Bool
    }
    
    init(homeRepository: HomeRepositoryProtocol) {
        self.homeRepository = homeRepository
    }
    
    func fetchInboxCount() async {
        guard !hasFetchedInboxCount else {
            return
        }
        
        inboxCount = (try? await homeRepository.fetchInboxCount()) ?? 0
        hasFetchedInboxCount = true
    }
    
    func startInboxCountPolling() {
        inboxCountPollingTask?.cancel()
        
        guard !AccountViewModel.shared.account.isAnonymous() else {
            return
        }
        
        inboxCountPollingTask = Task {
            var skipFirstWait: Bool = false
            let currentTime = Date().timeIntervalSince1970
            if currentTime - lastInboxCountPollingTime < TimeInterval(NotificationUserDefaultsUtils.notificationInterval * 60) {
                try? await Task.sleep(for: .seconds(lastInboxCountPollingTime + TimeInterval(NotificationUserDefaultsUtils.notificationInterval * 60) - currentTime))
                skipFirstWait = true
            }
            repeat {
                if !skipFirstWait {
                    try? await Task.sleep(for: .seconds(NotificationUserDefaultsUtils.notificationInterval * 60))
                } else {
                    skipFirstWait = false
                }
                if !Task.isCancelled {
                    inboxCount = (try? await homeRepository.fetchInboxCount()) ?? 0
                }
                lastInboxCountPollingTime = Date().timeIntervalSince1970
            } while !Task.isCancelled
        }
    }
    
    func stopInboxCountPolling() {
        inboxCountPollingTask?.cancel()
        inboxCountPollingTask = nil
    }
}
