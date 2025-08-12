//
// ReadPostDao.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-03
//

import GRDB
import Combine

struct ReadPostDao {
    private let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(readPost: ReadPost) async throws {
        try await dbPool.write { db in
            try readPost.insert(db, onConflict: .replace)
        }
    }
    
    func getAllReadPostsFuture(username: String, before: Int64?) -> Future<[ReadPost], Error> {
        Future { promise in
            Task {
                do {
                    let sql = """
                        SELECT * 
                        FROM read_posts 
                        WHERE username = ? AND (? IS NULL OR time < ?) 
                        ORDER BY time DESC 
                        LIMIT 25
                        """
                    let posts = try await dbPool.read { db in
                        try ReadPost.fetchAll(db, sql: sql, arguments: [username, before, before])
                    }
                    promise(.success(posts))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    func getAllReadPosts(username: String, before: Int64?) throws -> [ReadPost] {
        try dbPool.read { db in
            try ReadPost.fetchAll(db, sql: """
                SELECT *
                FROM read_posts
                WHERE username = ? AND (? IS NULL OR time < ?)
                ORDER BY time DESC
                LIMIT 25
                """, arguments: [username, before, before])
        }
    }
    
    func getReadPost(id: String) throws -> ReadPost? {
        try dbPool.read { db in
            try ReadPost.fetchOne(db, sql: """
            SELECT *
            FROM read_posts
            WHERE post_id = ?
            LIMIT 1
            """, arguments: [id])
        }
    }
    
    func getReadPostsCount(username: String) async throws -> Int {
        try await dbPool.read { db in
            try Int.fetchOne(db, sql: """
            SELECT COUNT(*)
            FROM read_posts
            WHERE username = ?
            """, arguments: [username])!
        }
    }
    
    func deleteOldestReadPosts(username: String) async throws {
        try await dbPool.write { db in
            try db.execute(sql: """
            DELETE FROM read_posts 
            WHERE rowid IN (SELECT rowid FROM read_posts ORDER BY time ASC LIMIT 100) 
            AND username = ?
            """, arguments: [username])
        }
    }
    
    func deleteAllReadPosts() throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM read_posts")
        }
    }
    
    func getReadPostsIdsByIds(ids: [String], username: String) throws -> Set<String> {
        try dbPool.write { db in
            let placeholders = Array(repeating: "?", count: ids.count).joined(separator: ", ")
            
            let arguments: [DatabaseValueConvertible?] = ids + [username]
            
            return try String.fetchSet(db, sql: """
                SELECT post_id FROM read_posts
                WHERE post_id IN (\(placeholders))
                AND username = ?
                """, arguments: StatementArguments(arguments))
        }
    }
    
    func getMaxReadPostEntrySize() -> Int { // in bytes
        return 20 + // max username size
               10 + // post_id size
               8   // time size
    }
}
