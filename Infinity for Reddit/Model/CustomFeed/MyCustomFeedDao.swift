//
// MyCustomFeedDao.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-03
//

import GRDB
import Combine

struct MyCustomFeedDao {
    private let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(myCustomFeed: MyCustomFeed) throws {
        try dbPool.write { db in
            try myCustomFeed.insert(db, onConflict: .replace)
        }
    }
    
    func insertAll(myCustomFeeds: [MyCustomFeed]) {
        try? dbPool.write { db in
            for data in myCustomFeeds {
                do {
                    try data.insert(db, onConflict: .replace)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func getAllMyCustomFeedsWithSearchQuery(username: String, searchQuery: String) -> AnyPublisher<[MyCustomFeed], Error> {
        ValueObservation.tracking { db in
            try MyCustomFeed.fetchAll(db, sql: """
                SELECT * 
                FROM custom_feeds 
                WHERE username = ? AND display_name LIKE '%' || ? || '%' 
                ORDER BY name COLLATE NOCASE ASC
                """, arguments: [username, searchQuery])
        }
        .publisher(in: dbPool) 
        .eraseToAnyPublisher()
    }
    
    func getAllMyCustomFeedsList(username: String) throws -> [MyCustomFeed] {
        try dbPool.read { db in
            try MyCustomFeed.fetchAll(db, sql: """
                SELECT * 
                FROM custom_feeds 
                WHERE username = ? 
                ORDER BY name COLLATE NOCASE ASC
                """, arguments: [username])
        }
    }
    
    func getAllFavoriteMyCustomFeedsWithSearchQuery(username: String, searchQuery: String) -> AnyPublisher<[MyCustomFeed], Error> {
        ValueObservation.tracking { db in
            try MyCustomFeed.fetchAll(db, sql: """
                SELECT * 
                FROM custom_feeds 
                WHERE username = ? AND is_favorite AND display_name LIKE '%' || ? || '%' 
                ORDER BY name COLLATE NOCASE ASC
                """, arguments: [username, searchQuery])
        }
        .publisher(in: dbPool)
        .eraseToAnyPublisher()
    }
    
    func getMyCustomFeed(path: String, username: String) throws -> MyCustomFeed? {
        try dbPool.read { db in
            try MyCustomFeed.fetchOne(db, sql: """
                SELECT * 
                FROM custom_feeds 
                WHERE path = ? AND username = ? COLLATE NOCASE LIMIT 1
                """, arguments: [path, username])
        }
    }
    
    func deleteMyCustomFeed(path: String, username: String) throws {
        try dbPool.write { db in
            try db.execute(
                sql: """
                    DELETE FROM custom_feeds 
                    WHERE path = ? AND username = ?
                    """,
                arguments: [path, username]
            )
        }
    }
    
    func anonymousDeleteMyCustomFeed(path: String) throws {
        try dbPool.write { db in
            try db.execute(
                sql: """
                    DELETE FROM custom_feeds 
                    WHERE path = ? AND username = 
                    """,
                arguments: [path, Account.ANONYMOUS_ACCOUNT.username]
            )
        }
    }
    
    func deleteAllUserMyCustomFeeds(username: String) throws {
        try dbPool.write { db in
            try db.execute(
                sql: """
                    DELETE FROM custom_feeds 
                    WHERE username = ?
                    """,
                arguments: [username]
            )
        }
    }
}
