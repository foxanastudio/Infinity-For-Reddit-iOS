//
//  PartialUserDao.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-03.
//

import GRDB

struct PartialUserDao {
    private let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insertAll(_ allPartialUserData: [PartialUserData]) async throws {
        try await dbPool.write { db in
            for partialUserData in allPartialUserData {
                try partialUserData.insert(db, onConflict: .replace)
            }
        }
    }
    
    func getPartialUserData(username: String) async throws -> PartialUserData? {
        try await dbPool.read { db in
            try PartialUserData.fetchOne(db, sql: """
                SELECT *
                FROM partial_users
                WHERE username = ? COLLATE NOCASE
                LIMIT 1
                """, arguments: [username])
        }
    }
}
