//
//  PostListingType.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-05.
//

import Alamofire

public struct PostListingMetadata: Hashable {
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
    
    static func getSubredditMetadadata(subredditName: String, accountViewModel: AccountViewModel) -> PostListingMetadata {
        return PostListingMetadata(
            postListingType:.subreddit(subredditName: subredditName),
            pathComponents: ["subreddit": subredditName],
            headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
            queries: nil,
            params: nil
        )
    }
}

public enum PostListingType: Codable, Hashable {
    case frontPage
    case subreddit(subredditName: String)
    case user(username: String, userWhere: UserWhere)
    case search(query: String, searchInSubredditOrUserName: String?, searchInMultiReddit: String?, searchInThingType: SearchInThingType)
    case customFeed(path: String)
    case anonymousFrontPage(concatenatedSubscriptions: String?)
    case anonymousCustomFeed(myCustomFeed: MyCustomFeed, concatenatedSubscriptions: String?)
    
    var isFrontPage: Bool {
        switch self {
        case .frontPage:
            return true
        case .anonymousFrontPage:
            return true
        default:
            return false
        }
    }
    
    var isPopularOrAll: Bool {
        switch self {
        case .subreddit(let subredditName):
            return subredditName == "popular" || subredditName == "all"
        default:
            return false
        }
    }
}

public enum UserWhere: String, Codable {
    case submitted = "submitted", upvoted = "upvoted", downvoted = "downvoted", hidden = "hidden", saved = "saved"
}

enum SortEmbeddingStyle {
    case inPath
    case inQuery(key: String)
    case none
}
