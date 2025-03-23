//
//  RedditAPI.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-02.
//

import Alamofire
import Foundation

enum RedditAPI: URLRequestConvertible {
    case getAccessToken(queries: [String: String]?, headers: HTTPHeaders, params: [String: String]?)
    case getUserData(username: String)
    case getFrontPagePosts(pathComponents: [String: String], queries: [String: String])
    case getSubredditPosts(pathComponents: [String: String], queries: [String: String])
    case getUserPosts(pathComponents: [String: String], queries: [String: String])
    case getSearchPosts(queries: [String: String])
    case getMultiredditPosts(pathComponents: [String: String], queries: [String: String])
    case getSubredditConcatPosts(pathComponents: [String: String], queries: [String: String])
    case getUserComments(pathComponents: [String: String], queries: [String: String])
    case getPostAndCommentsById(postId: String, queries: [String: String])
    
    private var baseURL: String {
        return "https://www.reddit.com"
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAccessToken:
            return .post
        case .getUserData, .getFrontPagePosts, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getMultiredditPosts, .getSubredditConcatPosts, .getUserComments, .getPostAndCommentsById:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getAccessToken:
            return "/api/v1/access_token"
        case .getUserData(let username):
            return "/user/\(username)/about.json"
        case .getFrontPagePosts(let pathComponents, _):
            return "/\(pathComponents["sortType"] ?? "best").json"
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
        case .getUserComments(let pathComponents, _):
            return "/user/\(pathComponents["username"] ?? "infinityAN")/comments.json"
        case .getPostAndCommentsById(let postId, _):
            return "/comments/\(postId).json"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .getAccessToken(_, _, let params):
            return params
        case .getUserData, .getFrontPagePosts, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getMultiredditPosts, .getSubredditConcatPosts, .getUserComments, .getPostAndCommentsById:
            return nil
        }
    }
    
    var queries: [String: String]? {
        switch self {
        case .getAccessToken(let queries, _, _):
            return queries
        case .getUserData:
            return ["raw_json": "1"]
        case .getFrontPagePosts(_, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
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
        case .getUserComments(_, let queries):
            return ["raw_json": "1", "sort": "best"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getPostAndCommentsById(_, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getAccessToken(_, let headers, _):
            return headers
        case .getUserData, .getFrontPagePosts, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getMultiredditPosts, .getSubredditConcatPosts, .getUserComments, .getPostAndCommentsById:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .getAccessToken, .getUserData, .getFrontPagePosts, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getMultiredditPosts, .getSubredditConcatPosts, .getUserComments, .getPostAndCommentsById:
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
