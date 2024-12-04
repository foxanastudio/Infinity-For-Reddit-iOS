//
// CommentFilterUsage.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB

struct CommentFilterUsage: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName: String = "comment_filter_usage"
    static let SUBREDDIT_TYPE = 1

    var name: String
    var usage: Int
    var nameOfUsage: String

    init(name: String, usage: Int, nameOfUsage: String) {
        self.name = name
        self.usage = usage
        self.nameOfUsage = nameOfUsage
    }

    private enum CodingKeys: String, CodingKey, ColumnExpression {
        case name, usage, nameOfUsage = "name_of_usage"
    }
}




