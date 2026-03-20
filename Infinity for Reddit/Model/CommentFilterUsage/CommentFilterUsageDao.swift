//
// CommentFilterUsageDao.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB
import Combine

struct CommentFilterUsageDao {
    let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(commentFilterUsage: CommentFilterUsage) async throws {
        try await dbPool.write { db in
            try commentFilterUsage.insert(db, onConflict: .replace)
        }
    }
    
    func insertAll(commentFilterUsageList: [CommentFilterUsage]) async throws {
        try await dbPool.write { db in
            for usage in commentFilterUsageList {
                try usage.insert(db, onConflict: .replace)
            }
        }
    }
    
    func deleteCommentFilterUsage(commentFilterUsage: CommentFilterUsage) async throws {
        try await dbPool.write { db in
            try db.execute(sql: "DELETE FROM comment_filter_usage WHERE comment_filter_id = ? AND usage_type = ? AND name_of_usage = ?", arguments: [commentFilterUsage.commentFilterId, commentFilterUsage.usageType.rawValue, commentFilterUsage.nameOfUsage])
        }
    }
    
    func getAllCommentFilterUsageLiveData(commentFilterId: Int) -> AnyPublisher<[CommentFilterUsage], Error> {
        ValueObservation
            .tracking { db in
                try CommentFilterUsage.fetchAll(db, sql: "SELECT * FROM comment_filter_usage WHERE comment_filter_id = ?", arguments: [commentFilterId])
            }
            .publisher(in: dbPool)
            .eraseToAnyPublisher()
    }
    
    func getAllCommentFilterUsage(name: String) async throws -> [CommentFilterUsage] {
        try await dbPool.read { db in
            try CommentFilterUsage.fetchAll(db, sql: "SELECT * FROM comment_filter_usage WHERE name_of_usage = ?", arguments: [name])
        }
    }
    
    func getAllCommentFilterUsageForBackup() async throws -> [CommentFilterUsage] {
        try await dbPool.read { db in
            try CommentFilterUsage.fetchAll(db)
        }
    }
}
