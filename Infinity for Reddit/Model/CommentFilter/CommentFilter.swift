//
// CommentFilter.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB

struct CommentFilter: Codable, FetchableRecord, PersistableRecord, Hashable {
    static let databaseTableName = "comment_filter"
    
    enum DisplayMode: Int, Codable {
        case removeComment = 0
        case collapseComment = 10
    }

    var id: Int?
    var name: String = "New Filter"

    var displayMode: DisplayMode = .removeComment

    var maxVote: Int = -1
    var minVote: Int = -1
    var excludeStrings: String?
    var excludeUsers: String?

    init(
        id: Int? = nil,
        name: String = "New Filter",
        displayMode: DisplayMode = .removeComment,
        maxVote: Int = -1,
        minVote: Int = -1,
        excludeStrings: String? = nil,
        excludeUsers: String? = nil
    ) {
        self.id = id
        self.name = name
        self.displayMode = displayMode
        self.maxVote = maxVote
        self.minVote = minVote
        self.excludeStrings = excludeStrings
        self.excludeUsers = excludeUsers
    }

    private enum CodingKeys: String, CodingKey, ColumnExpression {
        case id, name, displayMode = "display_mode", maxVote = "max_vote",
             minVote = "min_vote", excludeStrings = "exclude_strings",
             excludeUsers = "exclude_users"
    }
}
