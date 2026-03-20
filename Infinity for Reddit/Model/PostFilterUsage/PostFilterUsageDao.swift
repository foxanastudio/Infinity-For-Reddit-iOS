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
    
    func insert(postFilterUsage: PostFilterUsage) async throws {
        try await dbPool.write { db in
            try postFilterUsage.insert(db, onConflict: .replace)
        }
    }

    func insertAll(postFilterUsageList: [PostFilterUsage]) async throws {
        try await dbPool.write { db in
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
    
    func getAllPostFilterUsage(postFilterId: Int) async throws -> [PostFilterUsage] {
        try await dbPool.read { db in
            try PostFilterUsage.fetchAll(db, sql: "SELECT * FROM post_filter_usage WHERE post_filter_id = ?", arguments: [postFilterId])
        }
    }

    func getAllPostFilterUsageForBackup() async throws -> [PostFilterUsage] {
        try await dbPool.read { db in
            try PostFilterUsage.fetchAll(db)
        }
    }

    func deletePostFilterUsage(postFilterUsage: PostFilterUsage) async throws {
        try await dbPool.write { db in
            try db.execute(sql: "DELETE FROM post_filter_usage WHERE post_filter_id = ? AND usage_type = ? AND name_of_usage = ?", arguments: [postFilterUsage.postFilterId, postFilterUsage.usageType.rawValue, postFilterUsage.nameOfUsage])
        }
    }
}

