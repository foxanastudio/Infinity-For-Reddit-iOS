//
//  HistoryPostListingType.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-03.
//

extension HistoryPostListingType {
    var postFilterNameOfUsage: String {
        switch self {
        case .read:
            return PostFilterUsage.HISTORY_TYPE_USAGE_READ_POSTS
        case .upvoted:
            return PostFilterUsage.HISTORY_TYPE_USAGE_UPVOTED_POSTS
        case .downvoted:
            return PostFilterUsage.HISTORY_TYPE_USAGE_DOWNVOTED_POSTS
        case .hidden:
            return PostFilterUsage.HISTORY_TYPE_USAGE_HIDDEN_POSTS
        case .saved:
            return PostFilterUsage.HISTORY_TYPE_USAGE_SAVED_POSTS
        }
    }
}

extension HistoryPostListingType {
    var postHistoryTypeForDB: PostHistoryType {
        switch self {
        case .read:
            return PostHistoryType.readPosts
        case .upvoted:
            return PostHistoryType.upvoted
        case .downvoted:
            return PostHistoryType.downvoted
        case .hidden:
            return PostHistoryType.hidden
        case .saved:
            return PostHistoryType.saved
        }
    }
}
