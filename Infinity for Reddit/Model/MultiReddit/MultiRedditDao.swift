//
// MultiRedditDao.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-03
//

import GRDB
import Combine

struct MultiRedditDao {
    private let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(multiReddit: MultiReddit) throws {
        try dbPool.write { db in
            try multiReddit.insert(db, onConflict: .replace)
        }
    }
    
    func insertAll(multiReddits: [MultiReddit]) throws {
        try dbPool.write { db in
            for data in multiReddits {
                try data.insert(db, onConflict: .replace)
            }
        }
    }
    
    func getAllMultiRedditsWithSearchQuery(username: String, searchQuery: String) -> AnyPublisher<[MultiReddit], Error> {
        ValueObservation.tracking { db in
            try MultiReddit.fetchAll(db, sql: """
                SELECT * 
                FROM multi_reddits 
                WHERE username = ? AND display_name LIKE '%' || ? || '%' 
                ORDER BY name COLLATE NOCASE ASC
                """, arguments: [username, searchQuery])
        }
        .publisher(in: dbPool) 
        .eraseToAnyPublisher()
    }
    
    func getAllMultiRedditsList(username: String) throws -> [MultiReddit] {
        try dbPool.read { db in
            try MultiReddit.fetchAll(db, sql: """
                SELECT * 
                FROM multi_reddits 
                WHERE username = ? 
                ORDER BY name COLLATE NOCASE ASC
                """, arguments: [username])
        }
    }
    
    func getAllFavoriteMultiRedditsWithSearchQuery(username: String, searchQuery: String) -> AnyPublisher<[MultiReddit], Error> {
        ValueObservation.tracking { db in
            try MultiReddit.fetchAll(db, sql: """
                SELECT * 
                FROM multi_reddits 
                WHERE username = ? AND is_favorite AND display_name LIKE '%' || ? || '%' 
                ORDER BY name COLLATE NOCASE ASC
                """, arguments: [username, searchQuery])
        }
        .publisher(in: dbPool)
        .eraseToAnyPublisher()
    }
    
    func getMultiReddit(path: String, username: String) throws -> MultiReddit? {
        try dbPool.read { db in
            try MultiReddit.fetchOne(db, sql: """
                SELECT * 
                FROM multi_reddits 
                WHERE path = ? AND username = ? COLLATE NOCASE LIMIT 1
                """, arguments: [path, username])
        }
    }
    
    func deleteMultiReddit(name: String, username: String) throws {
        try dbPool.write { db in
            try db.execute(
                sql: """
                    DELETE FROM multi_reddits 
                    WHERE name = ? AND username = ?
                    """,
                arguments: [name, username]
            )
        }
    }
    
    func anonymousDeleteMultiReddit(path: String) throws {
        try dbPool.write { db in
            try db.execute(
                sql: """
                    DELETE FROM multi_reddits 
                    WHERE path = ?
                    """,
                arguments: [path]
            )
        }
    }
    
    func deleteAllUserMultiReddits(username: String) throws {
        try dbPool.write { db in
            try db.execute(
                sql: """
                    DELETE FROM multi_reddits 
                    WHERE username = ?
                    """,
                arguments: [username]
            )
        }
    }
}
