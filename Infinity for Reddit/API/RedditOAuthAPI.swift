//
//  RedditOAuthAPI.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-03.
//

import Alamofire
import Foundation

enum RedditOAuthAPI: URLRequestConvertible {
    case getMyInfo
    case getFrontPagePosts(pathComponents: [String: String], queries: [String: String])
    case getSubredditPosts(pathComponents: [String: String], queries: [String: String])
    case getUserPosts(pathComponents: [String: String], queries: [String: String])
    case getSearchPosts(queries: [String: String])
    case getMultiredditPosts(pathComponents: [String: String], queries: [String: String])
    case getSubredditConcatPosts(pathComponents: [String: String], queries: [String: String])
    case vote(params: [String: String])
    
    private var baseURL: String {
        return "https://oauth.reddit.com"
    }
    
    var method: HTTPMethod {
        switch self {
        case .getMyInfo:
            return .get
        case .getFrontPagePosts, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getMultiredditPosts, .getSubredditConcatPosts:
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
        case .getSubredditPosts(let pathComponents, let queries):
            return "/r/\(pathComponents["subreddit"] ?? "popular")/\(pathComponents["sortType"] ?? "hot").json"
        case .getUserPosts(let pathComponents, let queries):
            return "/user/\(pathComponents["username"] ?? "")/\(pathComponents["where"] ?? "submitted").json"
        case .getSearchPosts:
            return "search.json"
        case .getMultiredditPosts(let pathComponents, let queries):
            return "\(pathComponents["multipath"] ?? "popular").json"
        case .getSubredditConcatPosts(let pathComponents, let queries):
            return "/r/\(pathComponents["subreddit"] ?? "popular")/\(pathComponents["sortType"] ?? "hot").json"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .getMyInfo, .getFrontPagePosts:
            return nil
        case .vote(let params):
            return params
        case .getSubredditPosts:
            return nil
        case .getUserPosts:
            return nil
        case .getSearchPosts:
            return nil
        case .getMultiredditPosts:
            return nil
        case .getSubredditConcatPosts:
            return nil
        }
    }
    
    var queries: [String: String]? {
        switch self {
        case .getMyInfo:
            return ["raw_json": "1"]
        case .getFrontPagePosts(_, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .vote(_):
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
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getMyInfo:
            return nil
        case .getFrontPagePosts(_, _):
            return nil
        case .vote(_):
            return nil
        case .getSubredditPosts(_, _):
            return nil
        case .getUserPosts(_, _):
            return nil
        case .getSearchPosts(_):
            return nil
        case .getMultiredditPosts(_, _):
            return nil
        case .getSubredditConcatPosts(_, _):
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .getMyInfo:
            return URLEncoding.default
        case .getFrontPagePosts:
            return URLEncoding.default
        case .vote:
            return URLEncoding.default
        case .getSubredditPosts:
            return URLEncoding.default
        case .getUserPosts:
            return URLEncoding.default
        case .getSearchPosts:
            return URLEncoding.default
        case .getMultiredditPosts:
            return URLEncoding.default
        case .getSubredditConcatPosts:
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
