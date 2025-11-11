//
//  SubredditDataDao.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-01.
//

import GRDB
import Combine

struct SubredditDao {
    private let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(subredditData: SubredditData) throws {
        try? dbPool.write { db in
            try subredditData.insert(db, onConflict: .replace)
        }
    }
    
    func insertAll(subredditData: [SubredditData]) throws {
        try? dbPool.write { db in
            for data in subredditData{
                try data.insert(db, onConflict: .replace)
            }
        }
    }
    
    func deleteAllSubreddits() throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM subreddits")
        }
    }
    
    func getSubredditLiveDataByName(name: String) throws -> AnyPublisher<SubredditData?, Error> {
        ValueObservation.tracking { db in
            try SubredditData.fetchOne(db, sql: "SELECT * FROM subreddits WHERE name = ? COLLATE NOCASE LIMIT 1", arguments: [name])
        }
        .publisher(in: dbPool)
        .eraseToAnyPublisher()
    }
    
    func getSubredditDataByName(subredditName: String) throws -> SubredditData? {
        try dbPool.read { db in
            try SubredditData.fetchOne(db, sql: "SELECT * FROM subreddits WHERE name = ? COLLATE NOCASE LIMIT 1", arguments: [subredditName])
        }
    }
    
    func updateSubscription(isSubscribed: Bool) throws {
        try dbPool.write { db in
            try db.execute(
                sql: """
                UPDATE subreddits 
                SET is_subscribed = ?
                """,
                arguments: [isSubscribed]
            )
        }
    }
}
