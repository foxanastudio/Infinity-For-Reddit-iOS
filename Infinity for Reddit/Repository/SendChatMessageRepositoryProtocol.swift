//
//  SendChatMessageRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

protocol SendChatMessageRepositoryProtocol {
    func sendChatMessage(recipient: String, subject: String, message: String) async throws
}
