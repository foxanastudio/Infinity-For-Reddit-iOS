//
//  ReminderManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-07-14.
//

import UserNotifications
import GRDB

class ReminderManager {
    static let shared = ReminderManager()
    
    private let reminderDao: ReminderDao
    
    private init() {
        guard let resolvedDatabasePool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool in ReminderManager")
        }
        self.reminderDao = ReminderDao(dbPool: resolvedDatabasePool)
    }
    
    func setReminder(reminder: Reminder) async throws {
        try await reminderDao.insert(reminder: reminder)
        scheduleReminder(reminder: reminder)
    }
    
    private func scheduleReminder(reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "\(reminder.commentId.isEmpty ? "Post" : "Comment") Reminder"
        content.body = reminder.content
        content.sound = .default
        content.userInfo = [
            AppDeepLink.postId: reminder.postId,
            AppDeepLink.commentId: reminder.commentId,
            AppDeepLink.reminderTime: reminder.reminderTime
        ]

        let triggerDate = Date(timeIntervalSince1970: TimeInterval(reminder.reminderTime))

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: triggerDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: getIdentifier(reminder: reminder),
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
    
    func checkRemindersIfNecessary() {
        // 1 hour
        guard InternalStateUserDefaultsUtils.reminderCheckTimeInSeconds < Utils.getCurrentTimeEpochInSecond() - 3600 else {
            return
        }
        
        InternalStateUserDefaultsUtils.setReminderCheckTimeInSecondsNow()
        
        Task {
            var requestIds = Set(await UNUserNotificationCenter.current().pendingNotificationRequests().map(\.identifier))
            
            let remindersInDatabase = try await reminderDao.getAllRemindersForChecking()
            for reminder in remindersInDatabase {
                guard requestIds.count < 50 else {
                    break
                }
                
                let reminderId = getIdentifier(reminder: reminder)
                if !requestIds.contains(reminderId) {
                    self.scheduleReminder(reminder: reminder)
                    requestIds.insert(reminderId)
                }
            }
        }
    }
    
    func cancelReminder(reminder: Reminder) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [getIdentifier(reminder: reminder)]
            )
    }
    
    func deleteReminder(postId: String, commentId: String, reminderTime: Int) {
        Task {
            try? await reminderDao.deleteReminder(postId: postId, commentId: commentId, reminderTime: reminderTime)
        }
    }
    
    private func getIdentifier(reminder: Reminder) -> String {
        return "\(reminder.postId)-\(reminder.commentId)-\(reminder.createdAt)-\(reminder.reminderTime)"
    }
}
