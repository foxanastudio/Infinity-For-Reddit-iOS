//
// SubredditDetailsRepositoryProtocol.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-05-02
        
import Combine

public protocol SubredditDetailsRepositoryProtocol {
    func fetchSubredditDetails(subredditName: String) async throws -> SubredditData
    func subsribeSubreddit(subredditData: SubredditData, action: String) async throws
    func fetchUserFlairs(subredditName: String) async throws -> [UserFlair]
    func selectUserFlair(subredditName: String, userFlair: UserFlair?) async throws
}
