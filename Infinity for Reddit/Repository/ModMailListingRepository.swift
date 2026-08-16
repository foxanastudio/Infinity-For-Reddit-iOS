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
        case authRequiredError
        
        var errorDescription: String? {
            switch self {
            case .authRequiredError:
                return "Authentication required"
            }
        }
    }
    
    private let session: Session
    private let sessionName: String?
    
    public init(sessionName: String? = nil) {
        self.sessionName = sessionName
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self, name: self.sessionName) else {
            fatalError("Failed to resolve Session in ModMailListingRepository")
        }
        self.session = resolvedSession
    }
    
    public func fetchModMailListing(queries: [String : String],
                                    interceptor: RequestInterceptor? = nil
    ) async throws -> ModMailListing {
        if self.sessionName == "plain", interceptor == nil {
            throw ModMailListingRepositoryError.authRequiredError
        }
        
        let response = await self.session.request(
            RedditOAuthAPI.getModMailConversations(queries: queries),
            interceptor: interceptor
        )
        .validate()
        .serializingData()
        .response
        
        if let statusCode = response.response?.statusCode {
            printInDebugOnly("Status code: \(statusCode) Session: \(self.sessionName ?? "nil")")
        }
        
        if let data = response.data {
            printInDebugOnly(data)
            try Task.checkCancellation()
            
            let json = JSON(data)
            if let error = json.error {
                throw APIError.jsonDecodingError(error.localizedDescription)
            }
            
            return try ModMailListing(fromJson: json)
        }
        
        throw APIError.networkError("Status code: \(response.response?.statusCode ?? 0)")
    }

    public func markAllModMailAsRead(subredditNames: [String],
                                     state: String
    ) async throws {
        if self.sessionName == "plain" {
            throw ModMailListingRepositoryError.authRequiredError
        }

        guard !subredditNames.isEmpty else {
            return
        }

        let response = await self.session.request(
            RedditOAuthAPI.bulkReadModMail(
                params: [
                    "state": state,
                    "entity": subredditNames.joined(separator: ",")
                ]
            )
        )
        .serializingData(automaticallyCancelling: true)
        .response

        if let statusCode = response.response?.statusCode, !(200...299).contains(statusCode) {
            throw APIError.networkError("Mod mail bulk read failed with status code \(statusCode)")
        }

        if let error = response.error {
            throw APIError.networkError(error.localizedDescription)
        }
    }
}
