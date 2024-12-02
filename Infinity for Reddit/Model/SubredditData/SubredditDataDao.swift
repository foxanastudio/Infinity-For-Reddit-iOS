//
//  SubredditDataDao.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-01.
//

import GRDB
import Combine

struct SubredditDataDao {
    private let dbQueue: DatabaseQueue
    
    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
    
    func insert(subredditData: SubredditData) {
        try? dbQueue.write { db in
            try subredditData.insert(db)
        }
    }
    
    func deleteAllSubreddits() throws {
        _ = try dbQueue.write { db in
            try SubredditData.deleteAll(db)
        }
    }
    
    func getSubredditLiveDataByName(namePrefixed: String) -> AnyPublisher<SubredditData?, Error> {
        ValueObservation.tracking { db in
            try SubredditData.fetchOne(db, sql: "SELECT * FROM subreddits WHERE name = ? COLLATE NOCASE LIMIT 1", arguments: [namePrefixed])
        }
        .publisher(in: dbQueue)
        .eraseToAnyPublisher()
    }
    
    func getSubredditDataByName(namePrefixed: String) throws -> [SubredditData] {
        try dbQueue.read { db in
            try SubredditData.fetchAll(db, sql: "SELECT * FROM subreddits WHERE name = ? COLLATE NOCASE LIMIT 1", arguments: [namePrefixed])
        }
    }
}
