//
//  CreateModMailConversationRepository.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-07.
//

import Alamofire
import SwiftyJSON
import Foundation

class CreateModMailConversationRepository: CreateModMailConversationRepositoryProtocol {
    private let session: Session
    
    init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in CreateModMailConversationRepository")
        }
        self.session = resolvedSession
    }
    
    func fetchModeratedSubreddits() async throws -> [ModeratedSubreddit] {
        let response = await self.session.request(
            RedditOAuthAPI.getModMailSubreddits
        )
            .validate()
            .serializingData()
            .response
        
        if let statusCode = response.response?.statusCode {
            printInDebugOnly("Status code: \(statusCode)")
        }
        
        guard let data = response.data else {
            throw APIError.networkError("Status code: \(response.response?.statusCode ?? 0)")
        }
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        return try ModeratedSubredditListing(fromJson: json).subreddits
            .filter { !$0.name.hasPrefix("u_") }
    }
    
    func createConversation(
        subredditName: String,
        subject: String,
        body: String,
        to: String?,
        isAuthorHidden: Bool
    ) async throws -> ModMailConversationDetail {
        var params = [
            "srName": subredditName,
            "subject": subject,
            "body": body,
            "isAuthorHidden": String(isAuthorHidden)
        ]
        if let to {
            params["to"] = to
        }
        
        let response = await self.session.request(
            RedditOAuthAPI.createModMailConversation(params: params)
        )
            .serializingData(automaticallyCancelling: true)
            .response
        
        if let statusCode = response.response?.statusCode, !(200...299).contains(statusCode) {
            let explanation = response.data.map { JSON($0)["explanation"].stringValue } ?? ""
            if !explanation.isEmpty {
                throw APIError.invalidResponse(explanation.capitalizedFirst)
            }
            throw APIError.networkError("Mod mail conversation creation failed with status code \(statusCode)")
        }
        
        if let error = response.error {
            throw APIError.networkError(error.localizedDescription)
        }
        
        guard let data = response.data else {
            throw APIError.networkError("Mod mail conversation creation failed. No data available.")
        }
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        return try ModMailConversationDetail(fromJson: json)
    }
}
