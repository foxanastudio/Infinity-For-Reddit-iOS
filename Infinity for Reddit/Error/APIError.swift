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
    case anonymous403Error
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .jsonDecodingError(let message):
            return "Failed to decode the response: \(message)"
        case .invalidResponse(let message):
            return message
        case .anonymous403Error:
            return "Due to platform limitations, content cannot be loaded right now.\n\nYou can try again shortly or subscribe for a more consistent experience."
        }
    }
}
