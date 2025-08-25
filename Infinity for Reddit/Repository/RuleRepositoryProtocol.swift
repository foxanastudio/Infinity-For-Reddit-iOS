//
// RuleRepositoryProtocol.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-24
        
import Combine
import Alamofire

protocol RuleRepositoryProtocol {
    func fetchRules(subreddit: String, isAnonymous: Bool) async throws -> [Rule]
}
