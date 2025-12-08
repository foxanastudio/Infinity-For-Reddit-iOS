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
    @Published private var inboxCountPollingTask: Task<Void, Never>?
    private var hasFetchedInboxCount: Bool = false
    @Published private var lastInboxCountPollingTime: Int = 0
    
    struct InboxNavigationTarget: Equatable {
        let viewMessage: Bool
    }
    
    init(homeRepository: HomeRepositoryProtocol) {
        self.homeRepository = homeRepository
    }
    
    func fetchInboxCount() async {
        guard !hasFetchedInboxCount && !AccountViewModel.shared.account.isAnonymous() else {
            return
        }
        
        inboxCount = (try? await homeRepository.fetchInboxCount()) ?? 0
        hasFetchedInboxCount = true
    }
    
    func startInboxCountPolling(resetPollingTime: Bool = false) {
        inboxCountPollingTask?.cancel()
        if resetPollingTime {
            lastInboxCountPollingTime = 0
        }
        
        guard !AccountViewModel.shared.account.isAnonymous() else {
            return
        }
        
        inboxCountPollingTask = Task {
            var skipFirstWait: Bool = false
            let currentTime = Utils.getCurrentTimeEpochInSecond()
            if currentTime - lastInboxCountPollingTime < NotificationUserDefaultsUtils.notificationInterval * 60 {
                try? await Task.sleep(for: .seconds(lastInboxCountPollingTime + NotificationUserDefaultsUtils.notificationInterval * 60 - currentTime))
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
                lastInboxCountPollingTime = Utils.getCurrentTimeEpochInSecond()
            } while !Task.isCancelled
        }
    }
    
    func stopInboxCountPolling() {
        inboxCountPollingTask?.cancel()
        inboxCountPollingTask = nil
    }
}
