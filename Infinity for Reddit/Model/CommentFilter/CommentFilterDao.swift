//
// CommentFilterDao.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB
import Combine
import Foundation

struct CommentFilterDao {
    let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(commentFilter: CommentFilter) async throws {
        try await dbPool.write { db in
            try commentFilter.insert(db, onConflict: .replace)
        }
    }
    
    func insertAll(commentFilters: [CommentFilter]) async throws {
        try await dbPool.write { db in
            for filter in commentFilters {
                try filter.insert(db, onConflict: .replace)
            }
        }
    }
    
    func updateCommentFilter(updatedCommentFilter: CommentFilter) async throws {
        try await dbPool.write { db in
            if var existingCommentFilter = try CommentFilter.filter(Column("id") == updatedCommentFilter.id).fetchOne(db) {
                existingCommentFilter = updatedCommentFilter
                try existingCommentFilter.update(db)
            } else {
                throw NSError(domain: "CommentFilter", code: 404, userInfo: [NSLocalizedDescriptionKey: "CommentFilter with name \(updatedCommentFilter.name) not found."])
            }
        }
    }
    
    func deleteAllCommentFilters() async throws {
        try await dbPool.write { db in
            try db.execute(sql: "DELETE FROM comment_filter")
        }
    }
    
    func deleteCommentFilter(commentFilter: CommentFilter) async throws {
        try await dbPool.write { db in
            try db.execute(sql: "DELETE FROM comment_filter WHERE id = ?", arguments: [commentFilter.id])
        }
    }
    
    func deleteCommentFilter(id: Int) async throws {
        try await dbPool.write { db in
            try db.execute(sql: "DELETE FROM comment_filter WHERE id = ?", arguments: [id])
        }
    }
    
    func getCommentFilter(name: String) async throws -> CommentFilter? {
        try await dbPool.read { db in
            try CommentFilter.fetchOne(db, sql: "SELECT * FROM comment_filter WHERE name = ? LIMIT 1", arguments: [name])
        }
    }
    
    func getAllCommentFiltersLiveData() -> AnyPublisher<[CommentFilter], Error> {
        ValueObservation
            .tracking { db in try CommentFilter.fetchAll(db, sql: "SELECT * FROM comment_filter ORDER BY name") }
            .publisher(in: dbPool)
            .eraseToAnyPublisher()
    }
    
    func getAllCommentFilters() async throws -> [CommentFilter] {
        try await dbPool.read { db in
            try CommentFilter.fetchAll(db)
        }
    }
    
    func getValidCommentFilters(usageType: CommentFilterUsage.UsageType, nameOfUsage: String) async throws -> [CommentFilter] {
        try await dbPool.read { db in
            let sql = """
                SELECT * FROM comment_filter WHERE (comment_filter.id IN 
                    (SELECT comment_filter_usage.comment_filter_id FROM comment_filter_usage 
                     WHERE (usage_type = ? AND name_of_usage = ? COLLATE NOCASE))) 
                OR (comment_filter.id NOT IN 
                    (SELECT comment_filter_usage.comment_filter_id FROM comment_filter_usage))
            """
            return try CommentFilter.fetchAll(db, sql: sql, arguments: [usageType.rawValue, nameOfUsage])
        }
    }
    
    func getAllCommentFilterWithUsageLiveData() -> AnyPublisher<[CommentFilterWithUsage], Error> {
        ValueObservation
            .tracking { db in
                try dbPool.read { db in // Use dbPool.read for the transaction
                    try CommentFilter.fetchAll(db, sql: "SELECT * FROM comment_filter ORDER BY name")
                        .map { commentFilter in
                            let commentFilterUsages = try CommentFilterUsage
                                .fetchAll(db, sql: "SELECT * FROM comment_filter_usage WHERE name_of_usage = ?", arguments: [commentFilter.name])
                            return CommentFilterWithUsage(commentFilter: commentFilter, commentFilterUsageList: commentFilterUsages)
                        }
                }
            }
            .publisher(in: dbPool)
            .eraseToAnyPublisher()
    }
}
