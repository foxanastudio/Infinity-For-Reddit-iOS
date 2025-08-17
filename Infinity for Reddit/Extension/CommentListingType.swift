//
//  CommentListingType.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-17.
//

import Foundation

extension CommentListingType {
    var savedSortType: SortType {
        switch self {
        case .user(let username):
            return SortTypeUserDetailsUtils.getUserComment(username: username)
        }
    }
    
    func saveSortType(sortType: SortType) {
        switch self {
        case .user(let username):
            UserDefaults.sortType?.set(sortType.type.rawValue, forKey: SortTypeUserDetailsUtils.userCommentSortTypeKey + username)
            if let time = sortType.time {
                UserDefaults.sortType?.set(time.rawValue, forKey: SortTypeUserDetailsUtils.userCommentSortTimeKey + username)
            }
        }
    }
}
