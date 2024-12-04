//
// PostFilterDao.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB
import Combine

struct PostFilterDao {
    let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(postFilter: PostFilter) throws {
        try dbPool.write { db in
            try postFilter.insert(db, onConflict: .replace)
        }
    }
    
    func insertAll(postFilterList: [PostFilter]) throws {
        try dbPool.write { db in
            for data in postFilterList {
                try data.insert(db, onConflict: .replace)
            }
        }
    }
    
    func deleteAllPostFilters() throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM post_filter")
        }
    }
    
    func deletePostFilter(postFilter: PostFilter) throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM post_filter WHERE name = ?", arguments: [postFilter.name])
        }
    }

    func deletePostFilter(name: String) throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM post_filter WHERE name = ?", arguments: [name])
        }
    }
    
    func getPostFilter(name: String) throws -> PostFilter? {
        try dbPool.read { db in
            try PostFilter.fetchOne(db, sql: "SELECT * FROM post_filter WHERE name = ? LIMIT 1", arguments: [name])
        }
    }
    
    func getAllPostFiltersLiveData() -> AnyPublisher<[PostFilter], Error> {
        ValueObservation
            .tracking { db in try PostFilter.fetchAll(db, sql: "SELECT * FROM post_filter ORDER BY name") }
            .publisher(in: dbPool)
            .eraseToAnyPublisher()
    }
    
    func getAllPostFilters() throws -> [PostFilter] {
        try dbPool.read { db in
            try PostFilter.fetchAll(db)
        }
    }
    
    func getValidPostFilters(usage: Int, nameOfUsage: String) throws -> [PostFilter] {
        try dbPool.read { db in
            let sql = """
                SELECT * FROM post_filter 
                WHERE post_filter.name IN 
                    (SELECT post_filter_usage.name FROM post_filter_usage 
                     WHERE (usage = ? AND name_of_usage = ? COLLATE NOCASE) 
                     OR (usage = ? AND name_of_usage = '--'))
            """
            return try PostFilter.fetchAll(db, sql: sql, arguments: [usage, nameOfUsage, usage])
        }
    }
}
