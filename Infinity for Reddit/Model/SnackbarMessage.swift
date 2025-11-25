//
//  SnackbarMessage.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-25.
//

enum SnackbarMessage {
    case info(String)
    case error(Error)
    
    var text: String {
        switch self {
        case .info(let text):
            return text
        case .error(let error):
            return error.localizedDescription
        }
    }
}
