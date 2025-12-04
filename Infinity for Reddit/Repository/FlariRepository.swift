//
// FlariRepository.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-28
        
import Foundation
import Alamofire
import SwiftyJSON

class FlairRepository: FlairRepositoryProtocol {
    private let session: Session
    
    init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in FlairRepository")
        }
        self.session = resolvedSession
    }
    
    func fetchFlairs(subreddit: String) async throws -> [Flair] {
        try Task.checkCancellation()
        
        return try await self.session.request(
            RedditOAuthAPI.getFlairs(subredditName: subreddit)
        )
            .validate()
            .serializingDecodable([Flair].self)
            .value
    }
}
