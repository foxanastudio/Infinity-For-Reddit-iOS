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
    }
    
    private let session: Session
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
    }
    
    public func fetchInboxListing(messageWhere: MessageWhere, pathComponents: [String : String], queries: [String : String]) async throws -> InboxListing {
        try Task.checkCancellation()
        print("pathComponents: \(pathComponents)")
        let response = try await self.session.request(
            RedditOAuthAPI.getInbox(pathComponents: pathComponents, queries: queries)
        )
        .validate()
        .serializingData()
        .response
        
        if let statusCode = response.response?.statusCode {
            print("Status code: \(statusCode)")
        }
        
        let data = response.data
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw InboxRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        return InboxListingRootClass(fromJson: json, messageWhere: messageWhere).data
    }
}
