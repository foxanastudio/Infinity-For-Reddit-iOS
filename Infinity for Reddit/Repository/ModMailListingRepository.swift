//
//  ModMailListingRepository.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-08.
//

import Alamofire
import SwiftyJSON
import Foundation

public class ModMailListingRepository: ModMailListingRepositoryProtocol {
    enum ModMailListingRepositoryError: LocalizedError {
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
    
    public func fetchModMailListing(queries: [String : String],
                                    interceptor: RequestInterceptor? = nil
    ) async throws -> ModMailListing {
        if self.sessionName == "plain", interceptor == nil {
            throw ModMailListingRepositoryError.AuthRequiredError
        }
        
        let response = await self.session.request(
            RedditOAuthAPI.getModMailConversations(queries: queries),
            interceptor: interceptor
        )
            .validate()
            .serializingData()
            .response
        
        if let statusCode = response.response?.statusCode {
            printInDebugOnly("Status code: \(statusCode) Session: \(self.sessionName)")
        }
        
        let data = response.data
        printInDebugOnly(data)
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw ModMailListingRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        return try ModMailListing(fromJson: json)
    }
}
