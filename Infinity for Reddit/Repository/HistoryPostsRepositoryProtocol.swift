//
//  HistoryPostsRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-10.
//

protocol HistoryPostsRepositoryProtocol {
    func getReadPostsIdsByIds(saveReadPosts: Bool, account: Account, postIds: [String]) async -> Set<String>
    func getHistoryPostsIdsByIdsAnonymous(postIds: [String], postHistoryType: PostHistoryType) async -> Set<String>
    func getIfExistInHistoryPostsAnonymous(postId: String, postHistoryType: PostHistoryType) async -> Bool
}
