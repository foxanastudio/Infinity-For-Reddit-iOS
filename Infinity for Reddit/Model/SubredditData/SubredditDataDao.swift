//
//  SubredditDataDao.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-01.
//

import GRDB
import Combine

struct SubredditDataDao {
    private let dbPool: DatabasePool
    
    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }
    
    func insert(subredditData: SubredditData) {
        try? dbPool.write { db in
            try subredditData.insert(db)
        }
    }
    
    func deleteAllSubreddits() throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM subreddits")
        }
    }
    
    func getSubredditLiveDataByName(namePrefixed: String) -> AnyPublisher<SubredditData?, Error> {
        ValueObservation.tracking { db in
            try SubredditData.fetchOne(db, sql: "SELECT * FROM subreddits WHERE name = ? COLLATE NOCASE LIMIT 1", arguments: [namePrefixed])
        }
        .publisher(in: dbPool)
        .eraseToAnyPublisher()
    }
    
    func getSubredditDataByName(namePrefixed: String) throws -> [SubredditData] {
        try dbPool.read { db in
            try SubredditData.fetchAll(db, sql: "SELECT * FROM subreddits WHERE name = ? COLLATE NOCASE LIMIT 1", arguments: [namePrefixed])
        }
    }
}
