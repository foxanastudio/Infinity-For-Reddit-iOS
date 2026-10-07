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
        var subreddits = [ModeratedSubreddit]()
        var after: String? = nil
        
        repeat {
            let response = await self.session.request(
                RedditOAuthAPI.getModeratedSubreddits(queries: ["after": after ?? ""])
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
            
            let listing = try ModeratedSubredditListing(fromJson: json)
            subreddits.append(contentsOf: listing.subreddits)
            after = listing.after
        } while after?.isEmpty == false
        
        return subreddits
    }
}
