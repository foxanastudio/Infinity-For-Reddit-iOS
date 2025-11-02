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
    enum CommentListingRepositoryError: LocalizedError {
        case NetworkError(String)
        case JSONDecodingError(String)
        case commentIdNotFound
        
        var errorDescription: String? {
            switch self {
            case .NetworkError(let message):
                return message
            case .JSONDecodingError(let message):
                return message
            case .commentIdNotFound:
                return "Comment ID not found"
            }
        }
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
        pathComponents: [String: String],
        queries: [String: String]
    ) async throws -> CommentListing {
        let apiRequest: URLRequestConvertible
        switch commentListingType {
        case .user:
            apiRequest = RedditOAuthAPI.getUserComments(pathComponents: pathComponents, queries: queries)
        case .userSaved:
            apiRequest = RedditOAuthAPI.getUserSavedComments(pathComponents: pathComponents, queries: queries)
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
    
    public func deleteComment(_ comment: Comment) async throws {
        guard let name = comment.name else {
            throw CommentListingRepositoryError.commentIdNotFound
        }
        let params = ["id": name]
        
        try Task.checkCancellation()
        
        _ = try await self.session.request(RedditOAuthAPI.deletePostOrComment(params: params))
            .validate()
            .serializingDecodable(Empty.self, automaticallyCancelling: true)
            .value
    }
}
