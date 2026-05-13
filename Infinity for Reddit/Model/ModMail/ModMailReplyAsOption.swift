//
//  ModMailReplyAsOption.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-05-12.
//

import Foundation

enum ModMailReplyAsOption: String, CaseIterable, Hashable {
    case subreddit
    case user
    case modsOnly

    var isAuthorHidden: Bool {
        switch self {
        case .subreddit:
            return true
        case .user, .modsOnly:
            return false
        }
    }

    var isInternal: Bool {
        self == .modsOnly
    }

    func authorName(currentUsername: String, subredditName: String) -> String {
        switch self {
        case .subreddit:
            return subredditName.isEmpty ? currentUsername : subredditName
        case .user, .modsOnly:
            return currentUsername
        }
    }

    func title(currentUsername: String, subredditName: String) -> String {
        switch self {
        case .subreddit:
            return "r/\(subredditName.isEmpty ? currentUsername : subredditName)"
        case .user:
            return "u/\(currentUsername)"
        case .modsOnly:
            return "Mods only"
        }
    }
}
