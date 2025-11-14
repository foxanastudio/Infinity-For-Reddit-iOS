//
//  HomeRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-14.
//

import Alamofire
import GRDB
import SwiftyJSON
import Foundation

class HomeRepository: HomeRepositoryProtocol {
    enum HomeRepositoryError: LocalizedError {
        case NetworkError(String)
        case JSONDecodingError(String)
        case userDataLoadFailed
        
        var errorDescription: String? {
            switch self {
            case .NetworkError(let message):
                return message
            case .JSONDecodingError(let message):
                return message
            case .userDataLoadFailed:
                return "Failed to load user data"
            }
        }
    }
    
    private let session: Session
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in UserDetailsRepository")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool in UserDetailsRepository")
        }
        self.session = resolvedSession
    }
    
    func fetchInboxCount() async throws -> Int {
        let data = try await self.session.request(
            RedditAPI.getUserData(username: AccountViewModel.shared.account.username)
        )
        .validate()
        .serializingData()
        .value
        
        let json = JSON(data)
        if let error = json.error {
            throw HomeRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        return json["data"]["inbox_count"].intValue
    }
}
