//
// RuleRepository.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-24
        
import Combine
import Alamofire
import SwiftyJSON
import Foundation

public class RuleRepository: RuleRepositoryProtocol {
    enum RuleRepositoryError: Error {
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
    
    func fetchRules(subreddit: String, isAnonymous: Bool) async throws -> [Rule] {
        try Task.checkCancellation()
        
        let data = try await self.session.request(
            RedditAPI.getRules(subredditName: subreddit)
        )
        .validate()
        .serializingData()
        .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw RuleRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        return RuleRootClass(fromJson: json).toRules()
    }
}
