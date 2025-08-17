//
//  CommentListingMetaData.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-15.
//  

import Alamofire

public struct CommentListingMetadata {
    var commentListingType: CommentListingType
    var pathComponents: [String: String]
    var headers: HTTPHeaders?
    var queries: [String: String]?
    var params: [String: String]?
    
    init(commentListingType: CommentListingType,
         pathComponents: [String: String] = [:],
         headers: HTTPHeaders? = nil,
         queries: [String: String]? = nil,
         params: [String: String]? = nil
    ) {
        self.commentListingType = commentListingType
        self.pathComponents = pathComponents
        self.headers = headers
        self.queries = queries
        self.params = pathComponents
    }
}

public enum CommentListingType: Codable {
    case user(username: String)
}
