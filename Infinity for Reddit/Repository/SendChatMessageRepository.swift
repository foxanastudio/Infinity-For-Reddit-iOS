//
//  SendChatMessageRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import Alamofire
import Foundation

class SendChatMessageRepository: SendChatMessageRepositoryProtocol {
    private let session: Session
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in SendChatMessageRepository")
        }
        self.session = resolvedSession
    }
    
    func sendChatMessage(recipient: String, subject: String, message: String) async throws {
        let params: [String: String] = ["api_type": "json", "return_rtjson": "true", "subject": subject, "text": message, "to": recipient]
        
        _ = try await self.session.request(RedditOAuthAPI.composeMessage(params: params))
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
    }
}
