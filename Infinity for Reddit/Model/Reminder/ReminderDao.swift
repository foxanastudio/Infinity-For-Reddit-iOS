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
    
    func getAllReminders() async throws -> [Reminder] {
        try await dbPool.read { db in
            try Reminder.fetchAll(db, sql: """
                SELECT * 
                FROM reminders
                ORDER BY reminder_time
                """)
        }
    }
    
    func getAllRemindersPublisher() -> AnyPublisher<[Reminder], Error> {
        ValueObservation.tracking { db in
            try Reminder.fetchAll(db, sql: """
                    SELECT * 
                    FROM reminders
                    ORDER BY reminder_time
                    """)
        }
        .publisher(in: dbPool)
        .eraseToAnyPublisher()
    }
    
    func deleteReminder(_ reminder: Reminder) async throws {
        try await dbPool.write { db in
            try db.execute(sql: "DELETE FROM reminders WHERE post_id = ? AND comment_id = ? AND reminder_time = ?",
                           arguments: [reminder.postId, reminder.commentId, reminder.reminderTime])
        }
    }
}
