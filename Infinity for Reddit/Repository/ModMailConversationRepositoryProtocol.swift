//
//  ModMailConversationRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-15.
//

import Alamofire

public protocol ModMailConversationRepositoryProtocol {
    func fetchModMailConversation(conversationId: String, interceptor: RequestInterceptor?) async throws -> ModMailConversationDetail
    
    func sendMessage(message: String, conversationId: String, isAuthorHidden: Bool, isInternal: Bool) async throws -> ModMailConversationDetail
}
