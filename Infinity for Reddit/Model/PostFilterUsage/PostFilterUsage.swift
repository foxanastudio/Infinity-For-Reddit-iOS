//
// PostFilterUsage.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB

struct PostFilterUsage: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "post_filter_usage"
    static let HOME_TYPE = 1
    static let SUBREDDIT_TYPE = 2
    static let USER_TYPE = 3
    static let MULTIREDDIT_TYPE = 4
    static let SEARCH_TYPE = 5
    static let HISTORY_TYPE = 6
    static let HISTORY_TYPE_USAGE_READ_POSTS = "-read-posts"
    static let NO_USAGE = "--"

    var name: String
    var usage: Int
    var nameOfUsage: String

    init(name: String, usage: Int, nameOfUsage: String) {
        self.name = name
        self.usage = usage
        self.nameOfUsage = nameOfUsage.isEmpty ? Self.NO_USAGE : nameOfUsage
    }

    private enum CodingKeys: String, CodingKey, ColumnExpression {
        case name, usage, nameOfUsage = "name_of_usage"
    }
}
