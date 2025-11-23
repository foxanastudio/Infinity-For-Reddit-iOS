//
//  APIError.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-14.
//

import Foundation

enum APIError: LocalizedError {
    case networkError(String)
    case jsonDecodingError(String)
    case invalidResponse(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .jsonDecodingError(let message):
            return "Failed to decode the response: \(message)"
        case .invalidResponse(let message):
            return message
        }
    }
}
