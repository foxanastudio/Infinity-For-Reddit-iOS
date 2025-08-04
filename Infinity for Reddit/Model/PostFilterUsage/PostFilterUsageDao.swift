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
    
    func getAllPostFilterUsageLiveData(postFilterId: Int) -> AnyPublisher<[PostFilterUsage], Error> {
        ValueObservation
            .tracking { db in
                try PostFilterUsage.fetchAll(db, sql: "SELECT * FROM post_filter_usage WHERE post_filter_id = ?", arguments: [postFilterId])
            }
            .publisher(in: dbPool)
            .eraseToAnyPublisher()
    }
    
    func getAllPostFilterUsage(postFilterId: Int) throws -> [PostFilterUsage] {
        try dbPool.read { db in
            try PostFilterUsage.fetchAll(db, sql: "SELECT * FROM post_filter_usage WHERE postFilterId = ?", arguments: [postFilterId])
        }
    }

    func getAllPostFilterUsageForBackup() throws -> [PostFilterUsage] {
        try dbPool.read { db in
            try PostFilterUsage.fetchAll(db)
        }
    }

    func deletePostFilterUsage(postFilterUsage: PostFilterUsage) throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM post_filter_usage WHERE post_filter_id = ? AND usage = ? AND name_of_usage = ?", arguments: [postFilterUsage.postFilterId, postFilterUsage.usageType.rawValue, postFilterUsage.nameOfUsage])
        }
    }
}

