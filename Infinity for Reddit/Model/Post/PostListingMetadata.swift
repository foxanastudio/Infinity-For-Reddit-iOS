//
//  PostListingType.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-05.
//

import Alamofire

public struct PostListingMetadata {
    var postListingType: PostListingType
    var pathComponents: [String: String]
    var headers: HTTPHeaders?
    var queries: [String: String]?
    var params: [String: String]?
    
    init(postListingType: PostListingType,
         pathComponents: [String: String] = [:],
         headers: HTTPHeaders? = nil,
         queries: [String: String]? = nil,
         params: [String: String]? = nil
    ) {
        self.postListingType = postListingType
        self.pathComponents = pathComponents
        self.headers = headers
        self.queries = queries
        self.params = pathComponents
    }
}

public enum PostListingType: Codable {
    case frontPage, subreddit, user(username: String, userWhere: UserWhere), search(query: String, searchInSubredditOrUserName: String?, searchInMultiReddit: String?, searchInThingType: Int), multireddit, subredditConcat
}

public enum UserWhere: String, Codable {
    case submitted = "submitted", upvoted = "upvoted", downvoted = "downvoted", hidden = "hidden", saved = "saved"
}
