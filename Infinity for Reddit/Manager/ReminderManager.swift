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
        scheculeReminder(reminder: reminder)
    }
    
    private func scheculeReminder(reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = reminder.content
        content.sound = .default

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
    
    func cancelReminder(reminder: Reminder) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [getIdentifier(reminder: reminder)]
            )
    }
    
    private func getIdentifier(reminder: Reminder) -> String {
        return "\(reminder.postId)-\(reminder.commentId)-\(reminder.reminderTime)"
    }
}
