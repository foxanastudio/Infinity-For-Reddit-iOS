//
//  UserDetailsRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-04.
//

import Combine
import Alamofire
import SwiftyJSON
import Foundation

public class UserDetailsRepository: UserDetailsRepositoryProtocol {
    enum UserDetailsRepositoryError: Error {
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
    
    public func fetchUserDetails(username: String) async throws -> UserData {
        try Task.checkCancellation()
        
        let data = try await self.session.request(
            RedditAPI.getUserData(username: username)
        )
        .validate()
        .serializingData()
        .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw UserDetailsRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        return UserDetailRootClass(fromJson: json).toUserData()
    }
    
    public func followUser(username: String, action: String) async throws {
        let params = ["action": action, "sr_name": "u_\(username)"]
        
        _ = try await self.session.request(RedditOAuthAPI.subsrcribeToSubreddit(params: params))
            .validate()
            .serializingDecodable(Empty.self)
            .value
    }
}
