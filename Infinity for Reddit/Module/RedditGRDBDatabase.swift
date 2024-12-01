//
//  RedditGRDBDatabase.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-11-30.
//

import Foundation
import GRDB

struct RedditGRDBDatabase {
    static let shared = try! RedditGRDBDatabase()
    
    let dbPool: DatabasePool
    
    private init() throws {
        let path = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("reddit_data.sqlite")
            .path
        
        dbPool = try DatabasePool(path: path)
        //try setupMigrations()
    }
    
    private func setupMigrations() throws {
        // TODO for future database scheme migration
    }
}
