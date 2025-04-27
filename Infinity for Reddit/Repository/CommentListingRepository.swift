//
//  CommentListingRepository.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-15.
//  

import Combine
import Alamofire
import SwiftyJSON
import Foundation

public class CommentListingRepository: CommentListingRepositoryProtocol {

    enum CommentListingRepositoryError: Error {
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
    
    public func fetchComments(
        commentListingType: CommentListingType,
        pathComponents: [String: String]? = nil,
        queries: [String: String]? = [:],
        params: [String: String]? = [:]
    ) async throws -> CommentListing {
        let apiRequest: URLRequestConvertible
        switch commentListingType {
        case .user:
            apiRequest = RedditOAuthAPI.getUserComments(pathComponents: pathComponents!, queries: queries!)
        }
        
        try Task.checkCancellation()
        
        let data = try await self.session.request(apiRequest)
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw CommentListingRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        return try CommentListingRootClass(fromJson: json).data
    }
}
