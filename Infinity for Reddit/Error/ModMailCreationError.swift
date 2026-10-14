//
//  ModMailCreationError.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-14.
//

import Foundation

enum ModMailCreationError: LocalizedError {
    case subredditNotSelectedError
    case noRecipientError
    case noSubjectError
    case noMessageError
    
    var errorDescription: String? {
        switch self {
        case .subredditNotSelectedError:
            return "Please select a subreddit first."
        case .noRecipientError:
            return "Recipient is required."
        case .noSubjectError:
            return "Subject is required."
        case .noMessageError:
            return "Message is required."
        }
    }
}
