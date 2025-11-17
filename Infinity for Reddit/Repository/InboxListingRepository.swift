//
//  InboxListingRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-23.
//

import Alamofire
import SwiftyJSON
import Foundation

public class InboxListingRepository: InboxListingRepositoryProtocol {
    enum InboxRepositoryError: LocalizedError {
        case NetworkError(String)
        case JSONDecodingError(String)
        case AuthRequiredError
        
        var errorDescription: String? {
            switch self {
            case .NetworkError(let message):
                return message
            case .JSONDecodingError(let message):
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
    
    public func fetchInboxListing(messageWhere: MessageWhere,
                                  pathComponents: [String : String],
                                  queries: [String : String],
                                  interceptor: RequestInterceptor? = nil
    ) async throws -> InboxListing {
        var path = pathComponents
        path["where"] = messageWhere.rawValue
        
        if self.sessionName == "plain", interceptor == nil {
            throw InboxRepositoryError.AuthRequiredError
        }
        
        let response = await self.session.request(
            RedditOAuthAPI.getInbox(pathComponents: path, queries: queries),
            interceptor: interceptor
        )
        .validate()
        .serializingData()
        .response
        
        if let statusCode = response.response?.statusCode {
            print("Status code: \(statusCode) Session: \(self.sessionName)")
        }
        
        let data = response.data
        print(data)
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw InboxRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        return try InboxListingRootClass(fromJson: json, messageWhere: messageWhere).data
    }
    
    public func markAsRead(inbox: Inbox, interceptor: RequestInterceptor? = nil) async throws {
        if self.sessionName == "plain", interceptor == nil {
            throw InboxRepositoryError.AuthRequiredError
        }
        
        await self.session.request(
            RedditOAuthAPI.readMessage(params: ["id": inbox.name]),
            interceptor: interceptor
        )
            .validate()
            .serializingData(automaticallyCancelling: true)
            .response
    }
}
