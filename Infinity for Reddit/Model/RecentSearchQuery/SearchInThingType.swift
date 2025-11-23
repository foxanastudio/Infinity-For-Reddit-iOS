//
//  SearchInThingType.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-18.
//

public enum SearchInThingType: Int, Codable, CaseIterable, Hashable {
    case all = 0
    case subreddit = 1
    case user = 2
    case customFeed = 3
}
