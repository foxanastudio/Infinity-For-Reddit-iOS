//
//  RedditGRDBDatabase.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-11-30.
//

import Foundation
import GRDB

struct RedditGRDBDatabase {
    public static func create() throws -> DatabasePool {
        let path = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("reddit_data.sqlite")
            .path
        
        let dbPool = try DatabasePool(path: path)
        try setupDatabaseScheme(dbPool)
        try setupMigrations(dbPool)
        return dbPool
    }
    
    private static func setupMigrations(_ dbPool: DatabasePool) throws {
        // TODO for future database scheme migration
    }
    
    private static func setupDatabaseScheme(_ dbPool: DatabasePool) throws {
        try dbPool.write { db in
            try db.create(table: Account.databaseTableName, ifNotExists: true) { t in
                t.column("username", .text).primaryKey()
                t.column("profile_image_url", .text)
                t.column("banner_image_url", .text)
                t.column("karma", .integer)
                t.column("is_mod", .boolean)
                t.column("access_token", .text)
                t.column("refresh_token", .text)
                t.column("is_current_user", .boolean)
                t.column("code", .text)
            }
        }
    }
}
