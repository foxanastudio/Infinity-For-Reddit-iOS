//
// RuleRepository.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-24
        
import Combine
import Alamofire
import SwiftyJSON

public class RuleRepository: RuleRepositoryProtocol {
    private let session: Session
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
    }
    
    func fetchRules(subredditName: String) async throws -> [Rule] {
        try Task.checkCancellation()
        
        let data = try await session.request(RedditOAuthAPI.getRules(subredditName: subredditName))
            .validate()
            .serializingData()
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        return RuleRootClass(fromJson: json).toRules()
    }
}
