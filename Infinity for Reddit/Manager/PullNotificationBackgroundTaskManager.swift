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
    
    private let taskIdentifier = "com.foxanastudio.infinity.bg.refresh.inbox"
    
    private let accountDao: AccountDao
    private let inboxListingRepository: InboxListingRepositoryProtocol
    private let modMailListingRepository: ModMailListingRepositoryProtocol
    
    private init() {
        guard let resolvedDatabasePool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool in PullNotificationBackgroundTaskManager")
        }
        self.accountDao = AccountDao(dbPool: resolvedDatabasePool)
        self.inboxListingRepository = InboxListingRepository(sessionName: "plain")
        self.modMailListingRepository = ModMailListingRepository(sessionName: "plain")
    }
    
    func registerAndScheduleBackgroundTaskIfNecessary() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.scheduleBackgroundTask()
            
            let pullNotificationTask = Task {
                let success = await self.pullNotificationsForAllAccounts()
                task.setTaskCompleted(success: success)
            }
            
            task.expirationHandler = {
                printInDebugOnly("Background Task: Task is expiring, attempting to cancel.")
                pullNotificationTask.cancel()
                task.setTaskCompleted(success: false)
            }
        }
        
        guard NotificationUserDefaultsUtils.enableNotification else {
            return
        }
        
        scheduleBackgroundTask()
    }
    
    func scheduleBackgroundTask() {
        guard NotificationUserDefaultsUtils.enableNotification else {
            return
        }
        
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        let refreshInterval = NotificationUserDefaultsUtils.notificationInterval
        request.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(refreshInterval * 60))
        
        do {
            try BGTaskScheduler.shared.submit(request)
            printInDebugOnly("Background Task Manager: Successfully scheduled app refresh task.")
        } catch {
            let nsError = error as NSError
            if nsError.domain == "BGTaskSchedulerErrorDomain" {
                printInDebugOnly("Background Task Manager: App refresh task is already scheduled.")
            } else {
                printInDebugOnly("Background Task Manager: Could not schedule app refresh task: \(error)")
            }
        }
    }
    
    func cancelBackgroundTask() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
    
    private func getAllAccounts() async -> [Account]? {
        do {
            return try await accountDao.getAllAccounts()
        } catch {
            printInDebugOnly("Load accounts failed: \(error)")
            return nil
        }
    }

    func pullNotificationsForAllAccounts() async -> Bool {
        printInDebugOnly("pullNotificationsForAllAccounts()")
        guard let accounts = await getAllAccounts(), !accounts.isEmpty else {
            return false
        }
        
        var successful = true
        
        let lastTime = UserDefaults.notification.integer(forKey: UserDefaultsUtils.PULL_NOTIFICATION_TIME_KEY)
        let lastModMailTime = UserDefaults.notification.integer(forKey: UserDefaultsUtils.PULL_MODMAIL_NOTIFICATION_TIME_KEY)
        
        for account in accounts {
            let perAccountAccessTokenInterceptor = await RedditAccessTokenProvider.shared.getRedditPerAccountInterceptor(account: account)
            
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
                
                let (title, subtitle) = getTitleAndSubtitle(inbox)
                
                let notificationId = "com.foxanastudio.infinity-\(account.username)-\(inbox.id ?? Utils.randomString())"
                let threadId = "inbox.\(account.username.lowercased())"
                
                var info: [String: Any] = [
                    AppDeepLink.accountNameKey: account.username,
                    AppDeepLink.kindKey: inbox.kind
                ]
                if let fullname = inbox.name {
                    info[AppDeepLink.fullnameKey] = fullname
                }
                if let context = inbox.context {
                    info[AppDeepLink.contextKey] = context
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

            if account.isMod {
                guard let modMailListing = try? await fetchModMailListing(interceptor: perAccountAccessTokenInterceptor) else {
                    successful = false
                    continue
                }

                let conversations = modMailListing.orderedConversations
                    .sorted { $0.lastUpdatedUtc > $1.lastUpdatedUtc }
                    .prefix(20)

                for conversation in conversations {
                    guard conversation.lastUnread != nil,
                          conversation.lastUpdatedUtc > lastModMailTime else {
                        continue
                    }

                    let (title, subtitle) = getTitleAndSubtitle(conversation)
                    let body = modMailListing.latestMessagePreview(for: conversation)
                    let notificationId = "com.foxanastudio.infinity-modmail-\(account.username)-\(conversation.id ?? Utils.randomString())"
                    let threadId = "modmail.\(account.username.lowercased())"

                    try? await NotificationDelegate.shared.postNotification(
                        notificationId: notificationId,
                        threadId: threadId,
                        title: title,
                        subtitle: subtitle,
                        body: body.isEmpty ? "You've got a new mod mail message" : body,
                        userInfo: [
                            AppDeepLink.accountNameKey: account.username,
                            AppDeepLink.kindKey: AppDeepLink.modMailHost
                        ]
                    )
                }
            }
        }
        
        if successful {
            UserDefaults.notification.set(Date().timeIntervalSince1970, forKey: UserDefaultsUtils.PULL_NOTIFICATION_TIME_KEY)
            UserDefaults.notification.set(Date().timeIntervalSince1970, forKey: UserDefaultsUtils.PULL_MODMAIL_NOTIFICATION_TIME_KEY)
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

    private func fetchModMailListing(interceptor: RequestInterceptor? = nil) async throws -> ModMailListing {
        return try await modMailListingRepository.fetchModMailListing(
            queries: [
                "limit": "20",
                "sort": "recent",
                "state": "all"
            ],
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

    private func getTitleAndSubtitle(_ conversation: ModMailConversation) -> (title: String, subtitle: String) {
        let subject = conversation.subject?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let title = subject.isEmpty ? "r/\(conversation.owner.displayName ?? "-")" : subject
        let subtitle = "New mod mail r/\(conversation.owner.displayName ?? "-")"
        return (title, subtitle)
    }
}
