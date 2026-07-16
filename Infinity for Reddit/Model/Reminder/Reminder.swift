//
//  Reminder.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-07-14.
//

import GRDB
import Foundation

public struct Reminder: Codable, FetchableRecord, PersistableRecord, Equatable, Hashable {
    public static let databaseTableName = "reminders"
    
    var accountName: String
    var postId: String
    var commentId: String
    var content: String
    var createdAt: Int
    // In seconds
    var reminderTime: Int
    
    init(
        accountName: String,
        postId: String,
        commentId: String,
        content: String,
        createdAt: Int,
        reminderTime: Int
    ) {
        self.accountName = accountName
        self.postId = postId
        self.commentId = commentId
        self.content = content
        self.createdAt = createdAt
        self.reminderTime = reminderTime
    }
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case accountName = "username"
        case postId = "post_id"
        case commentId = "comment_id"
        case content
        case createdAt = "created_at"
        case reminderTime = "reminder_time"
    }
}
