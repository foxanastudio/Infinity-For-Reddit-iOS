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
    case getSubredditPosts(pathComponents: [String: String], queries: [String: String])
    case getUserPosts(pathComponents: [String: String], queries: [String: String])
    case getSearchPosts(queries: [String: String])
    case getMultiredditPosts(pathComponents: [String: String], queries: [String: String])
    case getSubredditConcatPosts(pathComponents: [String: String], queries: [String: String])
    case vote(params: [String: String])
    case getSubscribedThings(queries: [String: String])
    case getMyCustomFeeds
    case getUserComments(pathComponents: [String: String], queries: [String: String])
    
    private var baseURL: String {
        return "https://oauth.reddit.com"
    }
    
    var method: HTTPMethod {
        switch self {
        case .getMyInfo, .getFrontPagePosts, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getMultiredditPosts, .getSubredditConcatPosts, .getSubscribedThings, .getMyCustomFeeds, .getUserComments:
            return .get
        case .vote:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .getMyInfo:
            return "/api/v1/me"
        case .getFrontPagePosts(let pathComponents, _):
            return "/\(pathComponents["sortType"] ?? "best").json"
        case .vote:
            return "/api/vote"
        case .getSubredditPosts(let pathComponents, _):
            return "/r/\(pathComponents["subreddit"] ?? "popular")/\(pathComponents["sortType"] ?? "hot").json"
        case .getUserPosts(let pathComponents, _):
            return "/user/\(pathComponents["username"] ?? "infinityAN")/\(pathComponents["where"] ?? "submitted").json"
        case .getSearchPosts:
            return "search.json"
        case .getMultiredditPosts(let pathComponents, _):
            return "\(pathComponents["multipath"] ?? "popular").json"
        case .getSubredditConcatPosts(let pathComponents, _):
            return "/r/\(pathComponents["subreddit"] ?? "popular")/\(pathComponents["sortType"] ?? "hot").json"
        case .getSubscribedThings:
            return "/subreddits/mine/subscriber"
        case .getMyCustomFeeds:
            return "/api/multi/mine"
        case .getUserComments(let pathComponents, _):
            return "/user/\(pathComponents["username"] ?? "infinityAN")/comments.json"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .getMyInfo, .getFrontPagePosts, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getMultiredditPosts, .getSubredditConcatPosts, .getSubscribedThings, .getMyCustomFeeds, .getUserComments:
            return nil
        case .vote(let params):
            return params
        }
    }
    
    var queries: [String: String]? {
        switch self {
        case .getMyInfo:
            return ["raw_json": "1"]
        case .getFrontPagePosts(_, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .vote, .getMyCustomFeeds:
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
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getMyInfo(let headers):
            return headers
        case .getFrontPagePosts, .vote, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getMultiredditPosts, .getSubredditConcatPosts, .getSubscribedThings, .getMyCustomFeeds, .getUserComments:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .getMyInfo, .getFrontPagePosts, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getMultiredditPosts, .getSubredditConcatPosts, .vote, .getSubscribedThings, .getMyCustomFeeds, .getUserComments:
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
        print(url)
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
