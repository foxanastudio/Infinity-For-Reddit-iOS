//
//  SearchRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-18.
//

public protocol SearchRepositoryProtocol {
    func saveSearchQuery(username: String,
                         query: String,
                         searchInSubredditOrUserName: String?,
                         customFeedPath: String?,
                         customFeedDisplayName: String?,
                         searchInThingType: SearchInThingType,
                         time: Int64)
    func clearAllRecentSearchQueries(username: String)
    func deleteRecentSearchQueries(recentSearchQuery: RecentSearchQuery)
}
