//
//  SubredditListingRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-19.
//

import Alamofire
import SwiftyJSON

public class SubredditListingRepository: SubredditListingRepositoryProtocol {
    private let session: Session
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
    }
    
    public func fetchSubredditListing(
        queries: [String: String] = [:]
    ) async throws -> SubredditListing {
        let apiRequest = RedditOAuthAPI.searchSubreddits(queries: queries)
        
        try Task.checkCancellation()
        
        let data = try await self.session.request(apiRequest)
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        return try SubredditListingRootClass(fromJson: json).data
    }
}
