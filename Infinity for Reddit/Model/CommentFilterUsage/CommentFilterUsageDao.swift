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
    
    func insert(commentFilterUsage: CommentFilterUsage) throws {
        try dbPool.write { db in
            try commentFilterUsage.insert(db, onConflict: .replace)
        }
    }
    
    func insertAll(commentFilterUsageList: [CommentFilterUsage]) throws {
        try dbPool.write { db in
            for usage in commentFilterUsageList {
                try usage.insert(db, onConflict: .replace)
            }
        }
    }
    
    func deleteCommentFilterUsage(commentFilterUsage: CommentFilterUsage) throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM comment_filter_usage WHERE name = ? AND usage = ? AND name_of_usage = ?", arguments: [commentFilterUsage.name, commentFilterUsage.usage, commentFilterUsage.nameOfUsage])
        }
    }
    
    func getAllCommentFilterUsageLiveData(name: String) -> AnyPublisher<[CommentFilterUsage], Error> {
        ValueObservation
            .tracking { db in
                try CommentFilterUsage.fetchAll(db, sql: "SELECT * FROM comment_filter_usage WHERE name = ?", arguments: [name])
            }
            .publisher(in: dbPool)
            .eraseToAnyPublisher()
    }
    
    func getAllCommentFilterUsage(name: String) throws -> [CommentFilterUsage] {
        try dbPool.read { db in
            try CommentFilterUsage.fetchAll(db, sql: "SELECT * FROM comment_filter_usage WHERE name = ?", arguments: [name])
        }
    }
    
    func getAllCommentFilterUsageForBackup() throws -> [CommentFilterUsage] {
        try dbPool.read { db in
            try CommentFilterUsage.fetchAll(db)
        }
    }
}
