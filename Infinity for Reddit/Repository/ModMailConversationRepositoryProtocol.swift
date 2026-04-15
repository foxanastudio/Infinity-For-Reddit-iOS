//
//  ModMailConversationRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-15.
//

import Alamofire
import SwiftyJSON

public protocol ModMailConversationRepositoryProtocol {
    func fetchModMailConversation(conversationId: String, interceptor: RequestInterceptor?) async throws -> JSON
}
