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
    enum InboxRepositoryError: Error {
        case NetworkError(String)
        case JSONDecodingError(String)
        case AuthRequiredError(String)
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
        try Task.checkCancellation()
        
        var path = pathComponents
        path["where"] = messageWhere.rawValue
        
        var headers = HTTPHeaders()
        headers.add(name: APIUtils.USER_AGENT_KEY, value: APIUtils.USER_AGENT)
        
        if self.sessionName == "plain", interceptor == nil {
            throw InboxRepositoryError.AuthRequiredError(
                "Access token or interceptor is required for inbox/unread with plain session."
            )
        }
        
        let response = try await self.session.request(
            RedditOAuthAPI.getInbox(pathComponents: path, queries: queries, headers: headers),
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
}
