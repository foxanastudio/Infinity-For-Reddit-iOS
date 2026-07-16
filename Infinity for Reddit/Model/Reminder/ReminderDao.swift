//
//  ReminderDao.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-07-15.
//

import GRDB
import Combine

struct ReminderDao {
    private let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(reminder: Reminder) async throws {
        try await dbPool.write { db in
            try reminder.insert(db, onConflict: .replace)
        }
    }
}
