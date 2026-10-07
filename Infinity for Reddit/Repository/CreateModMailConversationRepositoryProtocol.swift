//
//  CreateModMailConversationRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-07.
//

protocol CreateModMailConversationRepositoryProtocol {
    func fetchModeratedSubreddits() async throws -> [ModeratedSubreddit]
}
