//
//  StreamableAPI.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-18.
//

import Alamofire
import Foundation

enum StreamableAPI: URLRequestConvertible {
    case getStreamableData(shortCode: String)
    
    private var baseURL: String {
        return APIUtils.STREAMABLE_API_BASE_URI
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        switch self {
        case .getStreamableData(let shortCode):
            return "/videos/\(shortCode)"
        }
    }
    
    var parameters: [String: String]? {
        return nil
    }
    
    var queries: [String: String]? {
        return nil
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var encoding: ParameterEncoding {
        switch self {
        default:
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
