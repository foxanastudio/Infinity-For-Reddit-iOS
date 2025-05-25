//
//  InboxListingRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-23.
//

public protocol InboxListingRepositoryProtocol {
    func fetchInboxListing(messageWhere: MessageWhere, pathComponents: [String : String], queries: [String : String]) async throws -> InboxListing
}
