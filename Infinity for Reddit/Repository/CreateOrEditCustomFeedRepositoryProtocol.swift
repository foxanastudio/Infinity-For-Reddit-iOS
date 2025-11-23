//
//  CreateOrEditCustomFeedRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import IdentifiedCollections

protocol CreateOrEditCustomFeedRepositoryProtocol {
    func createOrUpdateCustomFeed(path: String, name: String, description: String, isPrivate: Bool, subredditsAndUsersInCustomFeed: IdentifiedArrayOf<Thing>, isUpdate: Bool) async throws -> MyCustomFeed
    func fetchCustomFeedDetails(path: String) async throws -> CustomFeed
    func fetchAnonymousCustomFeedSubreddits(path: String) async throws -> [AnonymousCustomFeedSubreddit]
}
