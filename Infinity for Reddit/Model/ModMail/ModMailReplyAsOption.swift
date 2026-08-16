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

    func getAuthorName(subredditName: String) -> String {
        switch self {
        case .subreddit:
            return subredditName.isEmpty ? AccountViewModel.shared.account.username : subredditName
        case .user, .modsOnly:
            return AccountViewModel.shared.account.username
        }
    }

    func getTitle(subredditName: String) -> String {
        switch self {
        case .subreddit:
            return "Reply as r/\(subredditName.isEmpty ? AccountViewModel.shared.account.username : subredditName)"
        case .user:
            return "Reply as u/\(AccountViewModel.shared.account.username)"
        case .modsOnly:
            return "Mods only"
        }
    }
}
