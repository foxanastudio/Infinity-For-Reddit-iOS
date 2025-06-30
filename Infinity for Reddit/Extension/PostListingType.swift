//
//  PostListingType.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-29.
//

extension PostListingType {
    var availableSortTypes: [SortType.Kind] {
        switch self {
        case .frontPage:
            return [.best, .hot, .new, .rising, .top, .controversial]
        case .subreddit:
            return [.hot, .new, .rising, .top, .controversial]
        case .user(username: let username, userWhere: let userWhere):
            return [.new, .hot, .top, .controversial]
        case .search(query: let query, searchInSubredditOrUserName: let searchInSubredditOrUserName, searchInMultiReddit: let searchInMultiReddit, searchInThingType: let searchInThingType):
            return [.relevance, .hot, .top, .new, .comments]
        case .multireddit:
            return [.hot, .new, .rising, .top, .controversial]
        case .subredditConcat:
            return [.hot, .new, .rising, .top, .controversial]
        }
    }
}
