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
    case getUserData(username: String, queries: [String: String]?)
    
    private var baseURL: String {
        return "https://www.reddit.com"
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAccessToken:
            return .post
        case .getUserData:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getAccessToken:
            return "/api/v1/access_token"
        case .getUserData(let username, _):
            return "/user/\(username)/about.json"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .getAccessToken(_, _, let params):
            return params
        case .getUserData(_, _):
            return nil
        }
    }
    
    var queries: [String: String]? {
        switch self {
        case .getAccessToken(queries: let queries, _, _):
            return queries
        case .getUserData(_, queries: let queries):
            return queries
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getAccessToken(_, let headers, _):
            return headers
        case .getUserData(_, _):
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .getAccessToken:
            return URLEncoding.default
        case .getUserData:
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
