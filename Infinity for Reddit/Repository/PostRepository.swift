//
//  PostRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-03.
//

import Combine
import Alamofire
import SwiftyJSON
import Foundation

public class PostRepository: PostRepositoryProtocol {
    enum PostRepositoryError: Error {
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
    
    public func votePost(
        post: Post,
        point: String
    ) async throws {
        do {
            let params = ["dir": point, "id": post.name!, "rank": "10"]
            
            try Task.checkCancellation()
            
            _ = try await self.session.request(RedditOAuthAPI.vote(params: params))
                .validate()
                .serializingDecodable(Empty.self, automaticallyCancelling: true)
                .value
        }
    }
}
