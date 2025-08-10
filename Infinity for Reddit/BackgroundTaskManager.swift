//
// BackgroundTaskManager.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-06

import Foundation
import BackgroundTasks
import UserNotifications

class BackgroundTasksManager {
    
    // MARK: - Properties
    let taskIdentifier = "com.docilealligator.infinityforreddit.bg.refresh.inbox"
    private let userDefaults: UserDefaults
    
    // MARK: - Singleton
    static let shared = BackgroundTasksManager()
    
    init () {
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
    }
    
    // MARK: - Public Methods
    public func checkForNewData() async throws -> Bool {
        if AccountViewModel.shared.account.isAnonymous() {
            return false
        }
        
#if DEBUG
        print("DEBUG: force hasNewMessages = true (skip fetch & writes)")
        return true
#endif
        
        let inboxListingRepository = InboxListingRepository()
        
        let messageWhere = MessageWhere.unread
        let pathComponents: [String: String] = ["where": "\(messageWhere)"]
        let queries: [String: String] = ["limit": "50"]
        
        let inboxListing = try await inboxListingRepository.fetchInboxListing(
            messageWhere: messageWhere,
            pathComponents: pathComponents,
            queries: queries
        )
        try Task.checkCancellation()
        
        let inboxes = inboxListing.inboxes ?? []
        let createdUTCs: [TimeInterval] = inboxes.compactMap { inbox in
            let raw = (inbox.createdUtc as Float?)
            guard let raw else {
                return nil
            }
            let timeInterval = TimeInterval(raw)
            return timeInterval > 0 ? timeInterval : nil
        }
        
        guard !createdUTCs.isEmpty else {
            return false
        }
        
        let maxCreatedUTC = createdUTCs.max()!
        
        let key = "lastNotifiedUTC"
        let lastNotifiedUTC = self.userDefaults.object(forKey: key) as? TimeInterval
        
        if lastNotifiedUTC == nil {
            self.userDefaults.set(maxCreatedUTC, forKey: key)
            print("Background Check: seeded lastNotifiedUTC = \(maxCreatedUTC)")
            return false
        }
        
        let hasNewMessages = createdUTCs.contains {
            $0 > (lastNotifiedUTC ?? 0)
        }
        print("Background Check: maxCreatedUTC=\(maxCreatedUTC), lastNotifiedUTC=\(lastNotifiedUTC ?? 0), hasNewMessages=\(hasNewMessages)")


        
        if hasNewMessages {
            self.userDefaults.set(maxCreatedUTC, forKey: key)
            self.userDefaults.set(true, forKey: "hasNewMessages")
        }
        
        return hasNewMessages
    }
    
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            let backgroundTask = Task {
                await self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
            
            // Set the expiration handler. This is called if the task takes too long.
            task.expirationHandler = {
                print("Background Task: Task is expiring, attempting to cancel.")
                backgroundTask.cancel()
            }
        }
        
        scheduleAppRefresh()
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60)
        
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
    
    func sendLocalNotification(title: String, body: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        try await UNUserNotificationCenter.current().addRequest(request)
        print("Local notification request added successfully via async wrapper.")
    }
    
    // MARK: - Task Handling
    private func handleAppRefresh(task: BGAppRefreshTask) async {
        
        scheduleAppRefresh()
        
        do {
            print("Background Task (async): Starting task.")
            if try await checkForNewData() {
                print("Background Task (async): New data found, sending notification.")
                try await sendLocalNotification(title: "You've got new message! (background)", body: "Check your inbox for new messages.")
                task.setTaskCompleted(success: true)
            } else {
                print("Background Task (async): No new data found.")
                task.setTaskCompleted(success: true)
            }
        } catch is CancellationError {
            print("Background Task (async): Task was cancelled.")
            task.setTaskCompleted(success: false)
        } catch {
            print("Background Task (async): Task failed with error: \(error)")
            task.setTaskCompleted(success: false)
        }
    }
    
    // MARK: - Helper Methods
    private func shouldSendNotification(for listing: InboxListing) -> Bool {
        return !(listing.inboxes?.isEmpty ?? true)
    }
}
