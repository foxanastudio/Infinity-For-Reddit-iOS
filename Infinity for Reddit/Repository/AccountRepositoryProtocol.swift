//
//  AccountRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-03-09.
//

import Foundation

protocol AccountRepositoryProtocol {
    func startRedditLogin(contextProvider: AuthPresentationContextProvider, onCallback: @escaping (URL?, Error?) -> Void)
    func extractCode(callbackURL: URL) -> String?
    func setUpAccount(code: String) async throws
    func getRedditSettings() async throws -> RedditSettings
}
