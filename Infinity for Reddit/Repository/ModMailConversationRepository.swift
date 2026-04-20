//
//  ModMailConversationRepository.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-15.
//

import Alamofire
import SwiftyJSON
import Foundation

public class ModMailConversationRepository: ModMailConversationRepositoryProtocol {
    enum ModMailConversationRepositoryError: LocalizedError {
        case NetworkError(String)
        case JSONDecodingError(String)
        case sendMessageError(String)
        case AuthRequiredError
        
        var errorDescription: String? {
            switch self {
            case .NetworkError(let message):
                return message
            case .JSONDecodingError(let message):
                return message
            case .sendMessageError(let message):
                return message
            case .AuthRequiredError:
                return "Authentication required"
            }
        }
    }
    
    private let session: Session
    private let sessionName: String?
    
    public init(sessionName: String? = nil) {
        self.sessionName = sessionName
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self, name: self.sessionName) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
    }
    
    public func fetchModMailConversation(conversationId: String,
                                         interceptor: RequestInterceptor? = nil
    ) async throws -> ModMailConversationDetail {
        if self.sessionName == "plain", interceptor == nil {
            throw ModMailConversationRepositoryError.AuthRequiredError
        }
        
        let response = await self.session.request(
            RedditOAuthAPI.getModMailConversation(conversationId: conversationId),
            interceptor: interceptor
        )
        .validate()
        .serializingData()
        .response
        
        if let statusCode = response.response?.statusCode {
            printInDebugOnly("Status code: \(statusCode) Session: \(self.sessionName ?? "nil")")
        }
        
        let data = response.data
        printInDebugOnly(data)
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw ModMailConversationRepositoryError.JSONDecodingError(error.localizedDescription)
        }

        return try ModMailConversationDetail(fromJson: json)
    }

    public func sendMessage(message: String,
                            conversationId: String,
                            isAuthorHidden: Bool,
                            isInternal: Bool
    ) async throws -> ModMailConversationDetail {
        if self.sessionName == "plain" {
            throw ModMailConversationRepositoryError.AuthRequiredError
        }

        let params = [
            "body": message,
            "isAuthorHidden": isAuthorHidden ? "true" : "false",
            "isInternal": isInternal ? "true" : "false"
        ]

        let data = try await
            self.session.request(
                RedditOAuthAPI.sendModMailMessage(conversationId: conversationId, params: params)
            )
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value

        try Task.checkCancellation()

        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }

        return try ModMailConversationDetail(fromJson: json)
    }
}
