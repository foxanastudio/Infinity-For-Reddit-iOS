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
            printInDebugOnly("Status code: \(statusCode) Session: \(self.sessionName ?? "nil")")
        }
        
        let data = response.data
        if let data {
            printInDebugOnly(data)
        }
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw ModMailListingRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        return try ModMailListing(fromJson: json)
    }

    public func markAllModMailAsRead(subredditNames: [String],
                                     state: String
    ) async throws {
        if self.sessionName == "plain" {
            throw ModMailListingRepositoryError.AuthRequiredError
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
            throw ModMailListingRepositoryError.NetworkError("Mod mail bulk read failed with status code \(statusCode)")
        }

        if let error = response.error {
            throw error
        }
    }
}
