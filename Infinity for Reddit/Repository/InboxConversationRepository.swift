//
//  InboxConversationRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-21.
//

import Alamofire
import SwiftyJSON
import Foundation

public class InboxConversationRepository: InboxConversationRepositoryProtocol {
    enum InboxConversationRepositoryError: LocalizedError {
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
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
    }
    
    public func sendMessage(message: String, fullNameToReplyTo: String) async throws -> Inbox {
        let params = ["api_type": "json", "return_rtjson": "true", "text": message, "thing_id": fullNameToReplyTo]
        
        let data = try await self.session.request(RedditOAuthAPI.sendCommentOrReplyToMessage(params: params))
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        let errorArray = json["json"]["errors"].array
        if let errorArray = errorArray, !errorArray.isEmpty {
            if let lastErrorArray = errorArray.last?.array, !lastErrorArray.isEmpty {
                let errorString: String
                if lastErrorArray.count >= 2 {
                    errorString = lastErrorArray[1].stringValue
                } else {
                    errorString = lastErrorArray[0].stringValue
                }
                throw(InboxConversationRepositoryError.sendMessageError(errorString.prefix(1).uppercased() + errorString.dropFirst()))
            } else {
                throw(InboxConversationRepositoryError.sendMessageError("Error sending message"))
            }
        }
        
        let inboxArray = json["json"]["data"]["things"].array
        if let inboxArray = inboxArray {
            if let inbox = inboxArray.first {
                return try Inbox(fromJson: inbox["data"], kind: inbox["kind"].stringValue, messageWhere: nil)
            }
        }
        
        throw(InboxConversationRepositoryError.sendMessageError("Error sending message"))
    }
}
