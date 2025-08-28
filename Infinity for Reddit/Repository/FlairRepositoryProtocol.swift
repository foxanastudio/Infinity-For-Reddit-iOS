//
// FlairRepositoryProtocol.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-28
        

import Foundation

protocol FlairRepositoryProtocol {
    func fetchFlairs(subreddit: String) async throws -> [Flair]
}
