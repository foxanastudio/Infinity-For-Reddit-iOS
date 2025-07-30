//
//  RedditOAuthAPI.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-03.
//

import Alamofire
import Foundation

enum RedditOAuthAPI: URLRequestConvertible {
    case getMyInfo(headers: HTTPHeaders)
    case getFrontPagePosts(pathComponents: [String: String], queries: [String: String])
    case getUserData(username: String)
    case getSubredditData(subredditName: String)
    case getSubredditPosts(pathComponents: [String: String], queries: [String: String])
    case getUserPosts(pathComponents: [String: String], queries: [String: String])
    case getSearchPosts(queries: [String: String])
    case getMultiredditPosts(pathComponents: [String: String], queries: [String: String])
    case getSubredditConcatPosts(pathComponents: [String: String], queries: [String: String])
    case vote(params: [String: String])
    case getSubscribedThings(queries: [String: String])
    case getMyCustomFeeds
    case getUserComments(pathComponents: [String: String], queries: [String: String])
    case subsrcribeToSubreddit(params: [String: String])
    case getPostAndCommentsById(postId: String, queries: [String: String])
    case getPostAndCommentsSingleThreadById(postId: String, commentId: String, queries: [String: String])
    case searchSubreddits(queries: [String: String])
    case searchUsers(queries: [String: String])
    case getInbox(pathComponents: [String: String], queries: [String: String])
    case saveThing(params: [String: String])
    case unsaveThing(params: [String: String])
    case getMoreCommentsForCommentMore(params: [String: String])
    case sendCommentOrReplyToMessage(params: [String: String])
    
    private var baseURL: String {
        return "https://oauth.reddit.com"
    }
    
    var method: HTTPMethod {
        switch self {
        case .getMyInfo, .getFrontPagePosts, .getUserData, .getSubredditData, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getMultiredditPosts, .getSubredditConcatPosts, .getSubscribedThings, .getMyCustomFeeds, .getUserComments, .getPostAndCommentsById, .getPostAndCommentsSingleThreadById, .searchSubreddits, .searchUsers, .getInbox:
            return .get
        case .vote, .subsrcribeToSubreddit, .saveThing, .unsaveThing, .getMoreCommentsForCommentMore, .sendCommentOrReplyToMessage:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .getMyInfo:
            return "/api/v1/me"
        case .getUserData(let username):
            return "/user/\(username)/about.json"
        case .getSubredditData(let subredditName):
            return "r/\(subredditName)/about.json"
        case .getFrontPagePosts(let pathComponents, _):
            return "/\(pathComponents["sortType"] ?? "best").json"
        case .vote:
            return "/api/vote"
        case .getSubredditPosts(let pathComponents, _):
            return "/r/\(pathComponents["subreddit"] ?? "popular")/\(pathComponents["sortType"] ?? "hot").json"
        case .getUserPosts(let pathComponents, _):
            return "/user/\(pathComponents["username"] ?? "")/\(pathComponents["where"] ?? "submitted").json"
        case .getSearchPosts:
            return "search.json"
        case .getMultiredditPosts(let pathComponents, _):
            return "\(pathComponents["multipath"] ?? "").json"
        case .getSubredditConcatPosts(let pathComponents, _):
            return "/r/\(pathComponents["subreddit"] ?? "popular")/\(pathComponents["sortType"] ?? "hot").json"
        case .getSubscribedThings:
            return "/subreddits/mine/subscriber"
        case .getMyCustomFeeds:
            return "/api/multi/mine"
        case .getUserComments(let pathComponents, _):
            return "/user/\(pathComponents["username"] ?? "infinityAN")/comments.json"
        case .subsrcribeToSubreddit:
            return "/api/subscribe"
        case .getPostAndCommentsById(let postId, _):
            return "/comments/\(postId).json"
        case .getPostAndCommentsSingleThreadById(let postId, let commentId, _):
            return "/comments/\(postId)/placeholder/\(commentId).json"
        case .searchSubreddits:
            return "/subreddits/search.json"
        case .searchUsers:
            return "/search.json"
        case .getInbox(let pathComponents, _):
            return "/message/\(pathComponents["where"] ?? MessageWhere.inbox.rawValue).json"
        case .saveThing:
            return "/api/save"
        case .unsaveThing:
            return "/api/unsave"
        case .getMoreCommentsForCommentMore:
            return "/api/morechildren.json"
        case .sendCommentOrReplyToMessage:
            return "/api/comment"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .getMyInfo, .getFrontPagePosts, .getUserData, .getSubredditData, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getMultiredditPosts, .getSubredditConcatPosts, .getSubscribedThings, .getMyCustomFeeds, .getUserComments, .getPostAndCommentsById, .getPostAndCommentsSingleThreadById, .searchSubreddits, .searchUsers, .getInbox:
            return nil
        case .vote(let params), .subsrcribeToSubreddit(let params), .saveThing(let params), .unsaveThing(let params), .getMoreCommentsForCommentMore(let params), .sendCommentOrReplyToMessage(let params):
            return params
        }
    }
    
    var queries: [String: String]? {
        switch self {
        case .getMyInfo:
            return ["raw_json": "1"]
        case .getFrontPagePosts(_, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getUserData:
            return ["raw_json": "1"]
        case .getSubredditData:
            return ["raw_json": "1"]
        case .vote, .getMyCustomFeeds, .saveThing, .unsaveThing:
            return nil
        case .getSubredditPosts(_, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getUserPosts(_, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getSearchPosts(let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getMultiredditPosts(_, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getSubredditConcatPosts(_, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getSubscribedThings(let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getUserComments(_, let queries):
            return ["raw_json": "1", "sort": "best"].merging(queries, uniquingKeysWith: { _, new in new })
        case .subsrcribeToSubreddit(_):
            return nil
        case .getPostAndCommentsById(_, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getPostAndCommentsSingleThreadById(_, _, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .searchSubreddits(let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .searchUsers(let queries):
            return ["raw_json": "1", "type": "user"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getInbox(_, let queries):
            return ["raw_json": "1", "limit": "100"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getMoreCommentsForCommentMore:
            return ["raw_json": "1", "api_type": "json"]
        case .sendCommentOrReplyToMessage:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getMyInfo(let headers):
            return headers
        case .getFrontPagePosts, .getUserData, .getSubredditData, .vote, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getMultiredditPosts, .getSubredditConcatPosts, .getSubscribedThings, .getMyCustomFeeds, .getUserComments, .subsrcribeToSubreddit, .getPostAndCommentsById, .getPostAndCommentsSingleThreadById, .searchSubreddits, .searchUsers, .getInbox, .saveThing, .unsaveThing, .getMoreCommentsForCommentMore, .sendCommentOrReplyToMessage:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .getMyInfo, .getFrontPagePosts, .getUserData, .getSubredditData, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getMultiredditPosts, .getSubredditConcatPosts, .vote, .getSubscribedThings, .getMyCustomFeeds, .getUserComments, .subsrcribeToSubreddit, .getPostAndCommentsById, .getPostAndCommentsSingleThreadById, .searchSubreddits, .searchUsers, .getInbox, .saveThing, .unsaveThing, .getMoreCommentsForCommentMore, .sendCommentOrReplyToMessage:
            return URLEncoding.default
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var url = try baseURL.asURL().appendingPathComponent(path)
        //Setup query params
        if let queries = queries {
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            urlComponents.queryItems = queries.map { key, value in
                URLQueryItem(name: key, value: value)
            }
            if let updatedURL = urlComponents.url {
                url = updatedURL
            }
        }
        //Set up method and headers
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers ?? HTTPHeaders()
        
        //Setup URL encoded form data
        let formEncodedData = parameters?.map { key, value in
            "\(key)=\(value)"
        }.joined(separator: "&")
        request.httpBody = formEncodedData?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}
