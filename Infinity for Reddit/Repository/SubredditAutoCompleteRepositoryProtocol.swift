//
//  SubredditAutoCompleteRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-01.
//

protocol SubredditAutoCompleteRepositoryProtocol {
    func getSubredditAutoComplete(query: String, over18: Bool) async throws -> SubredditListing
}
