//
//  UserListingRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-22.
//

public protocol UserListingRepositoryProtocol {
    func fetchUserListing(queries: [String: String]) async throws -> UserListing
}
