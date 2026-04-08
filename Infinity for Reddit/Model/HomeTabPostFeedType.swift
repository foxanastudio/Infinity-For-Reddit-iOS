//
//  HomeTabPostFeedType.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-04-05.
//

enum HomeTabPostFeedType: Int {
    case frontPage = 1
    case subreddit = 2
    case user = 3
    case customFeed = 4
    
    var description: String {
        switch self {
        case .frontPage:
            return "Front Page"
        case .subreddit:
            return "Subreddit"
        case .user:
            return "User"
        case .customFeed:
            return "Custom Feed"
        }
    }
    
    var textFieldPlaceholder: String {
        switch self {
        case .subreddit:
            return "Subreddit Name (Without r/ prefix)"
        case .user:
            return "Username (Without u/ prefix)"
        case .customFeed:
            return "Path (/user/yourusername/m/yourmultiredditname) (only lowercase characters)"
        default:
            // Really shouldn't happen
            return ""
        }
    }
}
