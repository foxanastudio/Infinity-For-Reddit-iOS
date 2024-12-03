//
// SubscribedUserDataDao.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-03
//

import Combine
import GRDB

struct SubscribedUserDao {
    private let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(subscribedUserData: SubscribedUserData) throws {
        try dbPool.write { db in
            try subscribedUserData.insert(db, onConflict: .replace)
        }
    }
    
    func insertAll(subscribedUserDataList: [SubscribedUserData]) throws {
        try dbPool.write { db in
            for data in subscribedUserDataList {
                try data.insert(db, onConflict: .replace)
            }
        }
    }
    
    func getAllSubscribedUsersWithSearchQuery(accountName: String, searchQuery: String) -> AnyPublisher<[SubscribedUserData], Error> {
        ValueObservation.tracking { db in
            try SubscribedUserData.fetchAll(db, sql: """
                SELECT *
                FROM subscribed_users
                WHERE username = ? AND name LIKE '%' || ? || '%' COLLATE NOCASE
                ORDER BY name COLLATE NOCASE ASC
                """, arguments: [accountName, searchQuery])
        }
        .publisher(in: dbPool)
        .eraseToAnyPublisher()
    }
    
    func getAllSubscribedUsersList(accountName: String) throws -> [SubscribedUserData] {
        try dbPool.read { db in
            try SubscribedUserData.fetchAll(db, sql: """
                SELECT *
                FROM subscribed_users
                WHERE username = ? COLLATE NOCASE
                ORDER BY name COLLATE NOCASE ASC
                """, arguments: [accountName])
        }
    }
    
    func getAllFavoriteSubscribedUsersWithSearchQuery(accountName: String, searchQuery: String) -> AnyPublisher<[SubscribedUserData], Error> {
        ValueObservation.tracking { db in
            try SubscribedUserData.fetchAll(db, sql: """
                SELECT *
                FROM subscribed_users
                WHERE username = ? AND name LIKE '%' || ? || '%' COLLATE NOCASE AND is_favorite = 1
                ORDER BY name COLLATE NOCASE ASC
                """, arguments: [accountName, searchQuery])
        }
        .publisher(in: dbPool)
        .eraseToAnyPublisher()
    }
    
    func getSubscribedUser(name: String, accountName: String) throws -> SubscribedUserData? {
        try dbPool.read { db in
            try SubscribedUserData.fetchOne(db, sql: """
                SELECT *
                FROM subscribed_users
                WHERE name = ? COLLATE NOCASE AND username = ? COLLATE NOCASE
                LIMIT 1
                """, arguments: [name, accountName])
        }
    }
    
    func deleteSubscribedUser(name: String, accountName: String) throws {
        try dbPool.write { db in
            try db.execute(sql: """
                DELETE FROM subscribed_users
                WHERE name = ? COLLATE NOCASE AND username = ? COLLATE NOCASE
                """, arguments: [name, accountName])
        }
    }
    
}
