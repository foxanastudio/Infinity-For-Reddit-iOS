//
//  HistoryPostsRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-10.
//

protocol HistoryPostsRepositoryProtocol {
    func getReadPostsIdsByIds(readPostEnabled: Bool, account: Account, postIds: [String]) -> Set<String>
    func getHistoryPostsIdsByIdsAnonymous(account: Account, postIds: [String], postHistoryType: PostHistoryType) -> Set<String>
    func getIfExistInHistoryPostsAnonymous(account: Account, postId: String, postHistoryType: PostHistoryType) -> Bool
}
