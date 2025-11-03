//
// PostHistory.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-03
//

import GRDB

struct PostHistory: Codable, FetchableRecord, PersistableRecord, Equatable, Hashable {
    static let databaseTableName = "post_history"
    
    let username: String
    let postId: String
    let postHistoryType: PostHistoryType
    var time: Int64
    
    init(username: String, postId: String, postHistoryType: PostHistoryType, time: Int64) {
        self.username = username
        self.postId = postId
        self.postHistoryType = postHistoryType
        self.time = time
    }
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case username
        case postId = "post_id"
        case postHistoryType = "post_history_type"
        case time
    }
    
    enum Columns {
        static let username = Column(CodingKeys.username)
        static let postId = Column(CodingKeys.postId)
        static let postHistoryType = Column(CodingKeys.postHistoryType)
        static let time = Column(CodingKeys.time)
    }

    public static let databaseSelection: [SQLSelectable] = CodingKeys.allCases.map { $0 }
    
    // Equatable conformance
    static func == (lhs: PostHistory, rhs: PostHistory) -> Bool {
        return lhs.username == rhs.username && lhs.postId == rhs.postId && lhs.postHistoryType == rhs.postHistoryType
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(username)
        hasher.combine(postId)
    }
}

enum PostHistoryType: Int, Codable {
    case readPosts = 0
}
