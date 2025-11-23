//
// AnonymousMultiredditSubreddit.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB

struct AnonymousCustomFeedSubreddit: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "anonymous_custom_feed_subreddits"

    var path: String
    var username: String = Account.ANONYMOUS_ACCOUNT.username
    var subredditName: String
    var iconUrlString: String

    init(path: String, subredditName: String, iconUrlString: String) {
        self.path = path
        self.subredditName = subredditName
        self.iconUrlString = iconUrlString
    }

    private enum CodingKeys: String, CodingKey, ColumnExpression {
        case path, username, subredditName = "subreddit_name", iconUrlString = "icon_url_string"
    }
}
