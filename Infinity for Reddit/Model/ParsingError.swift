//
//  ParsingError.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-23.
//

import Foundation

enum ParsingError: LocalizedError {
    case missingField(String, expectedType: String)

    var errorDescription: String? {
        switch self {
        case .missingField(let field, let expectedType):
            return "Missing required field: \(field) (Expected type: \(expectedType))"
        }
    }
}
