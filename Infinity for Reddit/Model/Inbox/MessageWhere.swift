//
//  MessageWhere.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-23.
//

public enum MessageWhere: String, Codable {
    case inbox = "inbox"
    case unread = "unread"
    case sent = "sent"
    case comments = "comments"
    case messages = "messages"
    case messagesDetail = "messages_detail"
}
