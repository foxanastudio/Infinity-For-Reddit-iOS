//
//  ReminderListingRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-07-15.
//

import GRDB

class ReminderListingRepository: ReminderListingRepositoryProtocol {
    private let reminderDao: ReminderDao
    
    public init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError( "Failed to resolve DatabasePool in ReminderListingRepository")
        }
        self.reminderDao = ReminderDao(dbPool: resolvedDBPool)
    }
    
    func getReminders() async throws -> [Reminder] {
        return try await reminderDao.getAllReminders()
    }
}
