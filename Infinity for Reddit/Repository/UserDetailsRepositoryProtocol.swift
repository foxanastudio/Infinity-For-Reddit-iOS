//
//  UserDetailsRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-04.
//

import Combine

public protocol UserDetailsRepositoryProtocol {
    func fetchUserDetails(username: String) async throws -> UserData
    func followUser(userData: UserData, action: String) async throws
}
