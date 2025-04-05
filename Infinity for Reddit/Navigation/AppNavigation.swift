//
//  AppNavigation.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-03.
//

enum AppNavigation: Hashable {
    case postDetails(post: Post)
    case subredditDetails(subredditName: String)
    case userDetails(username: String)
}
