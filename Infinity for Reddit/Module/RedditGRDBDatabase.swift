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
        
        var config = Configuration()
        config.prepareDatabase { db in
            try db.execute(sql: "PRAGMA journal_mode = WAL")
        }
        
        let dbPool = try DatabasePool(path: path, configuration: config)
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
            
            try db.create(table: PostFilter.databaseTableName, ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
                t.column("maxVote", .integer)
                t.column("minVote", .integer)
                t.column("maxComments", .integer)
                t.column("minComments", .integer)
                t.column("maxAwards", .integer)
                t.column("minAwards", .integer)
                t.column("allowNSFW", .boolean)
                t.column("onlyNSFW", .boolean)
                t.column("onlySpoiler", .boolean)
                t.column("postTitleExcludesRegex", .text)
                t.column("postTitleContainsRegex", .text)
                t.column("postTitleExcludesStrings", .text)
                t.column("postTitleContainsStrings", .text)
                t.column("excludeSubreddits", .text)
                t.column("excludeUsers", .text)
                t.column("containFlairs", .text)
                t.column("excludeFlairs", .text)
                t.column("excludeDomains", .text)
                t.column("containDomains", .text)
                t.column("containTextType", .boolean)
                t.column("containLinkType", .boolean)
                t.column("containImageType", .boolean)
                t.column("containGifType", .boolean)
                t.column("containVideoType", .boolean)
                t.column("containGalleryType", .boolean)
            }
            
            try db.create(table: SubscribedSubredditData.databaseTableName, ifNotExists: true) { t in
                t.column("full_name", .text).notNull()
                t.column("name", .text).notNull()
                t.column("icon_url", .text)
                t.column("username", .text)
                    .notNull()
                    .references(Account.databaseTableName, onDelete: .cascade)
                t.column("favorite", .boolean).notNull().defaults(to: false)
                t.primaryKey(["full_name", "name"])
            }
            
            try db.create(table: SubscribedUserData.databaseTableName, ifNotExists: true) { t in
                t.column("name", .text).notNull()
                t.column("icon_url", .text)
                t.column("username", .text)
                    .notNull()
                    .references(Account.databaseTableName, onDelete: .cascade)
                t.column("favorite", .boolean).notNull().defaults(to: false)
                t.primaryKey(["name", "username"])
            }
        }
    }
}
