//
//  HistoryPostListingType.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-03.
//

extension HistoryPostListingType {
    var postFilterNameOfUsage: String {
        switch self {
        case .read:
            return PostFilterUsage.HISTORY_TYPE_USAGE_READ_POSTS
        }
    }
}
