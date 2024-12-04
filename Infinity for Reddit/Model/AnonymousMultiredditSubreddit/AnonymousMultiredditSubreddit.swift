//
// AnonymousMultiredditSubreddit.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB

struct AnonymousMultiredditSubreddit: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "anonymous_multireddit_subreddits"

    var path: String
    var username: String = Account.ANONYMOUS_ACCOUNT
    var subredditName: String

    init(path: String, subredditName: String) {
        self.path = path
        self.subredditName = subredditName
    }

    private enum CodingKeys: String, CodingKey, ColumnExpression {
        case path, username, subredditName = "subreddit_name"
    }
}
