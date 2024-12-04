//
// PostFilterUsageDao.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import GRDB
import Combine

struct PostFilterUsageDao {
    let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(postFilterUsage: PostFilterUsage) throws {
        try dbPool.write { db in
            try postFilterUsage.insert(db, onConflict: .replace)
        }
    }

    func insertAll(postFilterUsageList: [PostFilterUsage]) throws {
        try dbPool.write { db in
            for data in postFilterUsageList {
                try data.insert(db, onConflict: .replace)
            }
        }
    }
    
    func getAllPostFilterUsageLiveData(name: String) -> AnyPublisher<[PostFilterUsage], Error> {
        ValueObservation
            .tracking { db in
                try PostFilterUsage.fetchAll(db, sql: "SELECT * FROM post_filter_usage WHERE name = ?", arguments: [name])
            }
            .publisher(in: dbPool)
            .eraseToAnyPublisher()
    }
    
    func getAllPostFilterUsage(name: String) throws -> [PostFilterUsage] {
        try dbPool.read { db in
            try PostFilterUsage.fetchAll(db, sql: "SELECT * FROM post_filter_usage WHERE name = ?", arguments: [name])
        }
    }

    func getAllPostFilterUsageForBackup() throws -> [PostFilterUsage] {
        try dbPool.read { db in
            try PostFilterUsage.fetchAll(db)
        }
    }

    func deletePostFilterUsage(postFilterUsage: PostFilterUsage) throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM post_filter_usage WHERE name = ? AND usage = ? AND name_of_usage = ?", arguments: [postFilterUsage.name, postFilterUsage.usage, postFilterUsage.nameOfUsage])
        }
    }
}

