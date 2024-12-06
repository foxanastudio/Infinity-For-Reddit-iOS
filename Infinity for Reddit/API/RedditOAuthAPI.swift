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
    case getFrongPagePost(headers: HTTPHeaders)
    
    private var baseURL: String {
        return "https://oauth.reddit.com"
    }
    
    var method: HTTPMethod {
        switch self {
        case .getMyInfo:
            return .get
        case .getFrongPagePost:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getMyInfo:
            return "/api/v1/me"
        case .getFrongPagePost:
            return "/"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .getMyInfo(_):
            return nil
        case .getFrongPagePost:
            return nil
        }
    }
    
    var queries: [String: String]? {
        switch self {
        case .getMyInfo(_):
            return ["raw_json": "1"]
        case .getFrongPagePost(_):
            return ["raw_json": "1"]
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getMyInfo(let headers):
            return headers
        case .getFrongPagePost(let headers):
            return headers
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .getMyInfo:
            return URLEncoding.default
        case .getFrongPagePost:
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
