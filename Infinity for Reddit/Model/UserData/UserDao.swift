//
// UserDataDao.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-02
//

import GRDB
import Combine

struct UserDao {
    private let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(userData: UserData) async throws {
        try await dbPool.write { db in
            try userData.insert(db, onConflict: .replace)
        }
    }
    
    func deleteAllUsers() async throws {
        try await dbPool.write { db in
            try db.execute(sql: "DELETE FROM users")
        }
    }
    
    func getUserLiveData(userName: String) -> AnyPublisher<UserData?, Error> {
        ValueObservation.tracking { db in
            try UserData.fetchOne(db, sql: """
                SELECT * 
                FROM users 
                WHERE name = ? COLLATE NOCASE 
                LIMIT 1
                """, arguments: [userName])
        }
        .publisher(in: dbPool)
        .eraseToAnyPublisher()
    }
    
    func getUserData(username: String) async throws -> UserData? {
        try await dbPool.read { db in
            try UserData.fetchOne(db, sql: """
                SELECT *
                FROM users
                WHERE name = ? COLLATE NOCASE
                LIMIT 1
                """, arguments: [username])
        }
    }
}
