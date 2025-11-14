//
//  HomeRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-14.
//

protocol HomeRepositoryProtocol {
    func fetchInboxCount() async throws -> Int
}
