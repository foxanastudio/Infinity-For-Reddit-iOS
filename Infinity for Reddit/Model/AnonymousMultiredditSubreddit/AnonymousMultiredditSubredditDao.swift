//
// AnonymousMultiredditSubredditDao.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB

struct AnonymousMultiredditSubredditDao {
    private let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(anonymousMultiredditSubreddit: AnonymousMultiredditSubreddit) throws {
        try dbPool.write { db in
            try anonymousMultiredditSubreddit.insert(db, onConflict: .replace)
        }
    }
    
    func insertAll(anonymousMultiredditSubreddits: [AnonymousMultiredditSubreddit]) throws {
        try dbPool.write { db in
            for subreddit in anonymousMultiredditSubreddits {
                try subreddit.insert(db, onConflict: .replace)
            }
        }
    }
    
    func getAllAnonymousMultiRedditSubreddits(path: String) throws -> [AnonymousMultiredditSubreddit] {
        try dbPool.read { db in
            try AnonymousMultiredditSubreddit.fetchAll(
                db, sql: "SELECT * FROM anonymous_multireddit_subreddits WHERE path = ? ORDER BY subreddit_name COLLATE NOCASE ASC", arguments: [path]
            )
        }
    }
    
    func getAllSubreddits() throws -> [AnonymousMultiredditSubreddit] {
        try dbPool.read { db in
            try AnonymousMultiredditSubreddit.fetchAll(db)
        }
    }
}
