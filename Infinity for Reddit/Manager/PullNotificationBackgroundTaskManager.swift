//
// PullNotificationBackgroundTaskManager.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-06

import Foundation
import BackgroundTasks
import UserNotifications
import GRDB
import Alamofire

class PullNotificationBackgroundTaskManager {
    static let shared = PullNotificationBackgroundTaskManager()
    
    private let taskIdentifier = "com.docilealligator.infinityforreddit.bg.refresh.inbox"
    
    private let accountDao: AccountDao
    private let inboxListingRepository: InboxListingRepositoryProtocol
    
    private init() {
        guard let resolvedDatabasePool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        self.accountDao = AccountDao(dbPool: resolvedDatabasePool)
        self.inboxListingRepository = InboxListingRepository(sessionName: "plain")
        
        NotificationCenter.default.addObserver(
            forName: .notificationIntervalChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scheduleBackgroundTask()
        }
    }
    
    func registerAndScheduleBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            let pullNotificationTask = Task {
                let success = await self.pullNotificationsForAllAccounts()
                task.setTaskCompleted(success: success)
                self.scheduleBackgroundTask()
            }
            task.expirationHandler = {
                print("Background Task: Task is expiring, attempting to cancel.")
                pullNotificationTask.cancel()
            }
        }
        
        scheduleBackgroundTask()
    }
    
    func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        let refreshInterval = NotificationUserDefaultsUtils.notificationInterval
        request.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(refreshInterval * 60))
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background Task Manager: Successfully scheduled app refresh task.")
        } catch {
            let nsError = error as NSError
            if nsError.domain == "BGTaskSchedulerErrorDomain" {
                print("Background Task Manager: App refresh task is already scheduled.")
            } else {
                print("Background Task Manager: Could not schedule app refresh task: \(error)")
            }
        }
    }
    
    private func getAllAccounts() async -> [Account]? {
        do {
            return try accountDao.getAllAccounts()
        } catch {
            print("Load accounts failed: \(error)")
            return nil
        }
    }

    func pullNotificationsForAllAccounts() async -> Bool {
        guard let accounts = await getAllAccounts(), !accounts.isEmpty else {
            return false
        }
        
        var successful = true
        
        let lastTime = UserDefaults.notification.integer(forKey: UserDefaultsUtils.PULL_NOTIFICATION_TIME_KEY)
        var newTime = lastTime
        
        for account in accounts {
            let perAccountAccessTokenInterceptor = await TokenCenter.shared.getRedditPerAccountInterceptor(account: account)
            
            guard let unreadListing = try? await fetchInboxListing(account, interceptor: perAccountAccessTokenInterceptor) else {
                successful = false
                continue
            }
            
            let inboxes = (unreadListing.inboxes ?? [])
                .sorted {
                    $0.createdUtc > $1.createdUtc
                }
                .prefix(20)
            
            for inbox in inboxes {
                guard inbox.createdUtc > lastTime else {
                    continue
                }
                
                newTime = max(newTime, Int(inbox.createdUtc))
                
                let (title, subtitle) = getTitleAndSubtitle(inbox)
                
                let notificationId = "com.docilealligator.infinityforreddit-\(account.username)-\(inbox.id ?? Utils.randomString())"
                let threadId = "inbox.\(account.username.lowercased())"
                
                var info: [String: Any] = [
                    "accountName": account.username,
                    "kind": inbox.inboxKind
                ]
                if let fullname = inbox.name {
                    info["messageFullname"] = fullname
                }
                if let context = inbox.context {
                    info["context"] = context
                }
                
                try? await NotificationDelegate.shared.postNotification(
                    notificationId: notificationId,
                    threadId: threadId,
                    title: title,
                    subtitle: subtitle,
                    body: inbox.body.isEmpty ? "You've got a new message" : inbox.body,
                    userInfo: info
                )
            }
        }
        
        if successful {
            UserDefaults.notification.set(Date().timeIntervalSince1970, forKey: UserDefaultsUtils.PULL_NOTIFICATION_TIME_KEY)
        }
        return successful
    }
    
    private func fetchInboxListing(_ account: Account, interceptor: RequestInterceptor? = nil) async throws -> InboxListing {
        return try await inboxListingRepository.fetchInboxListing(
            messageWhere: .unread,
            pathComponents: [:],
            queries: ["limit": "20"],
            interceptor: interceptor
        )
    }
    
    private func getTitleAndSubtitle(_ inbox: Inbox) -> (title: String, subtitle: String) {
        let subject = inbox.subject.trimmingCharacters(in: .whitespacesAndNewlines).capitalizedFirst
        let fallback = subject.isEmpty ? "New notification" : subject
        
        switch inbox.inboxKind {
        case .comment, .link:
            return (!inbox.author.isEmpty ? inbox.author : "New comment", subject)
        case .account:
            return (!inbox.linkTitle.isEmpty ? inbox.linkTitle : fallback, "Account")
        case .message:
            return (!inbox.linkTitle.isEmpty ? inbox.linkTitle : fallback, "New message")
        case .subreddit:
            return (!inbox.linkTitle.isEmpty ? inbox.linkTitle : fallback, "Subreddit")
        case .award:
            return (!inbox.linkTitle.isEmpty ? inbox.linkTitle : fallback, "Award")
        case .unknown:
            return (!inbox.linkTitle.isEmpty ? inbox.linkTitle : fallback, "New notification")
        }
    }
}
