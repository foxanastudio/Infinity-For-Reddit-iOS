//
//  SubredditAutoCompleteRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-01.
//

import Alamofire
import SwiftyJSON

class SubredditAutoCompleteRepository: SubredditAutoCompleteRepositoryProtocol {
    private let session: Session
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in SubredditAutoCompleteRepository")
        }
        self.session = resolvedSession
    }
    
    func getSubredditAutoComplete(query: String, over18: Bool) async throws -> SubredditListing {
        let queries: [String: String] = ["query": query, "over18": over18 ? "true" : "false"]
        let apiRequest = RedditOAuthAPI.subredditAutoComplete(queries: queries)
        
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
