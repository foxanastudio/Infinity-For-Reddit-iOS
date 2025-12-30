//
//  SubscribedSubredditDataDao.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-02.
//

import Combine
import GRDB

struct SubscribedSubredditDao {
    private let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(subscribedSubredditData: SubscribedSubredditData) async throws {
        try await dbPool.write { db in
            try subscribedSubredditData.insert(db, onConflict: .replace)
        }
    }
    
    func insertAll(subscribedSubredditData: [SubscribedSubredditData]) async throws {
        try await dbPool.write { db in
            for data in subscribedSubredditData {
                try data.insert(db, onConflict: .replace)
            }
        }
    }
    
    func deleteAllSubscribedSubreddits() async throws {
        try await dbPool.write { db in
            try db.execute(sql: "DELETE FROM subscribed_subreddits")
        }
    }
    
    func getAllSubscribedSubredditsWithSearchQuery(accountName: String, searchQuery: String) -> AnyPublisher<[SubscribedSubredditData], Error> {
        ValueObservation.tracking { db in
            try SubscribedSubredditData
                .fetchAll(db, sql: """
                    SELECT * 
                    FROM subscribed_subreddits 
                    WHERE username = ? AND name LIKE '%' || ? || '%' 
                    ORDER BY name COLLATE NOCASE ASC
                    """,
                          arguments: [accountName, searchQuery])
        }
        .publisher(in: dbPool)
        .eraseToAnyPublisher()
    }
    
    func getAllSubscribedSubredditsList(accountName: String) async throws -> [SubscribedSubredditData] {
        try await dbPool.read { db in
            try SubscribedSubredditData.fetchAll(db, sql: """
                SELECT * 
                FROM subscribed_subreddits 
                WHERE username = ? COLLATE NOCASE 
                ORDER BY name COLLATE NOCASE ASC
                """,
                arguments: [accountName])
        }
    }
    
    func getAllFavoriteSubscribedSubredditsWithSearchQuery(accountName: String, searchQuery: String) -> AnyPublisher<[SubscribedSubredditData], Error> {
        ValueObservation.tracking { db in
            try SubscribedSubredditData
                .fetchAll(db, sql: """
                    SELECT * 
                    FROM subscribed_subreddits 
                    WHERE username = ? AND name LIKE '%' || ? || '%' 
                    COLLATE NOCASE AND is_favorite = 1 ORDER BY name COLLATE NOCASE ASC
                    """,
                          arguments: [accountName, searchQuery])
        }
        .publisher(in: dbPool)
        .eraseToAnyPublisher()
    }
    
    func getSubscribedSubreddit(subredditName: String, accountName: String) async throws -> SubscribedSubredditData? {
        try await dbPool.read { db in
            try SubscribedSubredditData.fetchOne(db, sql: """
            SELECT * 
            FROM subscribed_subreddits 
            WHERE name = ? COLLATE NOCASE AND username = ? COLLATE NOCASE 
            LIMIT 1
            """,
            arguments: [subredditName, accountName])
        }
    }
    
    func deleteSubscribedSubreddit(subredditName: String, accountName: String) async throws {
        try await dbPool.write { db in
            try db.execute(sql: """
                DELETE FROM subscribed_subreddits 
                WHERE name = ? COLLATE NOCASE AND username = ? COLLATE NOCASE
                """,
                arguments: [subredditName, accountName])
        }
    }
}
