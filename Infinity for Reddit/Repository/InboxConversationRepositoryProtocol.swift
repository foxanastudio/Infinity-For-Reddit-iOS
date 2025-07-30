//
//  InboxConversationRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-21.
//

public protocol InboxConversationRepositoryProtocol {
    func sendMessage(message: String, fullNameToReplyTo: String) async throws -> Inbox
}
