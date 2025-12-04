//
//  CommentRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-24.
//

import Combine
import Alamofire
import SwiftyJSON
import Foundation

public class CommentRepository: CommentRepositoryProtocol {
    private let session: Session
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
    }
    
    public func voteComment(
        comment: Comment,
        point: String
    ) async throws {
        do {
            let params = ["dir": point, "id": comment.name!, "rank": "10"]
            
            try Task.checkCancellation()
            
            _ = try await self.session.request(RedditOAuthAPI.vote(params: params))
                .validate()
                .serializingDecodable(Empty.self, automaticallyCancelling: true)
                .value
        }
    }
    
    public func saveComment(
        comment: Comment,
        save: Bool
    ) async throws {
        do {
            let params = ["id": comment.name!]
            
            try Task.checkCancellation()
            
            _ = try await self.session.request(save ? RedditOAuthAPI.saveThing(params: params) : RedditOAuthAPI.unsaveThing(params: params))
                .validate()
                .serializingDecodable(Empty.self, automaticallyCancelling: true)
                .value
        }
    }
}
