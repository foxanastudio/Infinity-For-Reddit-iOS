//
//  FilteredHistoryPostsViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-03.
//

import Foundation

class FilteredHistoryPostsViewModel: ObservableObject {
    @Published var postFilter: PostFilter
    
    init(postFilter: PostFilter) {
        self.postFilter = postFilter
    }
}
