//
//  JSONError.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-18.
//

import Foundation

enum JSONError: LocalizedError {
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid JSON data"
        }
    }
}
