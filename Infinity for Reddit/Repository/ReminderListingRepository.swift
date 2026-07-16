//
//  ReminderListingRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-07-15.
//

import GRDB
import Combine

class ReminderListingRepository: ReminderListingRepositoryProtocol {
    private let reminderDao: ReminderDao
    
    public init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError( "Failed to resolve DatabasePool in ReminderListingRepository")
        }
        self.reminderDao = ReminderDao(dbPool: resolvedDBPool)
    }
    
    func getRemindersPublisher() -> AnyPublisher<[Reminder], Error> {
        return reminderDao.getAllRemindersPublisher()
    }
    
    func deleteReminder(_ reminder: Reminder) async throws {
        try await reminderDao.deleteReminder(postId: reminder.postId, commentId: reminder.commentId, reminderTime: reminder.reminderTime)
    }
}
