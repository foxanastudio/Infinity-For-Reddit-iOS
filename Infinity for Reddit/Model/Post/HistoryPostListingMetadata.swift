//
//  HistoryPostListingMetadata.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-02.
//

import Alamofire

public struct HistoryPostListingMetadata: Hashable {
    var historyPostListingType: HistoryPostListingType
    
    init(historyPostListingType: HistoryPostListingType) {
        self.historyPostListingType = historyPostListingType
    }
}

public enum HistoryPostListingType: Codable, Hashable {
    case read
}
