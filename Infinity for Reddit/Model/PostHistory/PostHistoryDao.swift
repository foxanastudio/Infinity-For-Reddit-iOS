//
// PostHistoryDao.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-03
//

import GRDB
import Combine

struct PostHistoryDao {
    private let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(postHistory: PostHistory) async throws {
        try await dbPool.write { db in
            try postHistory.insert(db, onConflict: .replace)
        }
    }
    
    func getAllReadPostsFuture(username: String, before: Int64?) -> Future<[PostHistory], Error> {
        Future { promise in
            Task {
                do {
                    let sql = """
                        SELECT * 
                        FROM post_history 
                        WHERE username = ? AND (? IS NULL OR time < ?) AND post_history_type = ?
                        ORDER BY time DESC 
                        LIMIT 25
                        """
                    let posts = try await dbPool.read { db in
                        try PostHistory.fetchAll(db, sql: sql, arguments: [username, before, before, PostHistoryType.readPosts.rawValue])
                    }
                    promise(.success(posts))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    func getAllHistoryPosts(username: String, before: Int64?, postHistoryType: PostHistoryType) throws -> [PostHistory] {
        try dbPool.read { db in
            try PostHistory.fetchAll(db, sql: """
                SELECT *
                FROM post_history
                WHERE username = ? AND (? IS NULL OR time < ?) AND post_history_type = ?
                ORDER BY time DESC
                LIMIT 100
                """, arguments: [username, before, before, postHistoryType.rawValue])
        }
    }
    
    func getReadPost(id: String) throws -> PostHistory? {
        try dbPool.read { db in
            try PostHistory.fetchOne(db, sql: """
            SELECT *
            FROM post_history
            WHERE post_id = ? AND post_history_type = ?
            LIMIT 1
            """, arguments: [id, PostHistoryType.readPosts.rawValue])
        }
    }
    
    func getReadPostsCount(username: String) async throws -> Int {
        try await dbPool.read { db in
            try Int.fetchOne(db, sql: """
            SELECT COUNT(*)
            FROM post_history
            WHERE username = ? AND post_history_type = ?
            """, arguments: [username, PostHistoryType.readPosts.rawValue])!
        }
    }
    
    func deletePostHistory(username: String, postId: String, postHistoryType: PostHistoryType) async throws {
        try await dbPool.write { db in
            try db.execute(sql: """
            DELETE FROM post_history WHERE username = ? AND post_id = ? AND post_history_type = ?
            """, arguments: [username, postId, postHistoryType.rawValue])
        }
    }
    
    func deleteOldestReadPosts(username: String) async throws {
        try await dbPool.write { db in
            try db.execute(sql: """
            DELETE FROM post_history 
            WHERE rowid IN (SELECT rowid FROM post_history WHERE username = ? AND post_history_type = ? ORDER BY time ASC LIMIT 100)
            """, arguments: [username, PostHistoryType.readPosts.rawValue])
        }
    }
    
    func deleteAllReadPosts() throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM post_history WHERE post_history_type = ?", arguments: [PostHistoryType.readPosts.rawValue])
        }
    }
    
    func getHistoryPostsIdsByIds(ids: [String], username: String, postHistoryType: PostHistoryType) throws -> Set<String> {
        try dbPool.write { db in
            let placeholders = Array(repeating: "?", count: ids.count).joined(separator: ", ")
            
            let arguments: [DatabaseValueConvertible?] = ids + [username, postHistoryType.rawValue]
            
            return try String.fetchSet(db, sql: """
                SELECT post_id FROM post_history
                WHERE post_id IN (\(placeholders))
                AND username = ? AND post_history_type = ?
                """, arguments: StatementArguments(arguments))
        }
    }
    
    // TODO fix this
    func getMaxReadPostEntrySize() -> Int { // in bytes
        return 20 + // max username size
               10 + // post_id size
               8   // time size
    }
}
