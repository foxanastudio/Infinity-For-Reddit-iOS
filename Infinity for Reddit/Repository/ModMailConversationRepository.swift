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
        case sendMessageError(String)
        
        var errorDescription: String? {
            switch self {
            case .sendMessageError(let message):
                return message
            }
        }
    }
    
    private let session: Session
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in ModMailConversationRepository")
        }
        self.session = resolvedSession
    }
    
    public func fetchModMailConversation(conversationId: String) async throws -> ModMailConversationDetail {
        let response = await self.session.request(
            RedditOAuthAPI.getModMailConversation(conversationId: conversationId)
        )
        .validate()
        .serializingData()
        .response
        
        if let statusCode = response.response?.statusCode {
            printInDebugOnly("Status code: \(statusCode)")
        }
        
        if let data = response.data {
            printInDebugOnly(data)
            try Task.checkCancellation()
            
            let json = JSON(data)
            if let error = json.error {
                throw APIError.jsonDecodingError(error.localizedDescription)
            }

            return try ModMailConversationDetail(fromJson: json)
        }
        
        throw APIError.networkError("Status code: \(response.response?.statusCode ?? 0)")
    }

    public func sendMessage(message: String,
                            conversationId: String,
                            isAuthorHidden: Bool,
                            isInternal: Bool
    ) async throws -> ModMailConversationDetail {
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
