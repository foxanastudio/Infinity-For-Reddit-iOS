//
// BackgroundTaskManager.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-06

import Foundation
import BackgroundTasks
import UserNotifications

@MainActor
class BackgroundTasksManager {
    
    // MARK: - Properties
    let taskIdentifier = "com.docilealligator.infinityforreddit"
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
        let inboxListingRepository = InboxListingRepository()
        
        let messageWhere = MessageWhere.inbox
        let pathComponents: [String: String] = [:]
        let queries: [String: String] = ["limit": "1"]
        
        let inboxListing = try await inboxListingRepository.fetchInboxListing(
                    messageWhere: messageWhere,
                    pathComponents: pathComponents,
                    queries: queries
                )
                
        try Task.checkCancellation()
        
        guard let latestMessageID = inboxListing.inboxes.first?.id else {
            return false
        }
        
        let lastSeenMessageID = self.userDefaults.string(forKey: "lastSeenMessageID")
        print("Background Check: Latest ID from API is \(latestMessageID), last seen ID was \(lastSeenMessageID ?? "none").")
        
//        return latestMessageID != lastSeenMessageID
        
        // debug
        return true
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
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background Task Manager: Successfully scheduled app refresh task.")
        } catch {
            print("Background Task Manager: Could not schedule app refresh task: \(error)")
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
