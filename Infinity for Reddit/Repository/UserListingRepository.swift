//
//  UserListingRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-22.
//

import Alamofire
import SwiftyJSON

public class UserListingRepository: UserListingRepositoryProtocol {
    private let session: Session
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
    }
    
    public func fetchUserListing(
        queries: [String: String] = [:]
    ) async throws -> UserListing {
        let apiRequest = RedditOAuthAPI.searchUsers(queries: queries)
        
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
        
        return try UserListingRootClass(fromJson: json).data
    }
}
