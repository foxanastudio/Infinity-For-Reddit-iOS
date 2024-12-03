//
//  RedditAPI.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-02.
//

import Alamofire
import Foundation

enum RedditAPI: URLRequestConvertible {
    case getAccessToken(headers: HTTPHeaders, params: [String: String])
    
    private var baseURL: String {
        return "https://www.reddit.com"
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAccessToken:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .getAccessToken:
            return "/api/v1/access_token"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .getAccessToken(_, let params):
            return params
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getAccessToken(let headers, _):
            return headers
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .getAccessToken:
            return URLEncoding.default
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL().appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers ?? HTTPHeaders()
        
        let formEncodedData = parameters?.map { key, value in
            "\(key)=\(value)"
        }.joined(separator: "&")
        request.httpBody = formEncodedData?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}
