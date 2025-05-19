//
//  SearchResultsViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-18.
//

import Foundation

class SearchResultsViewModel: ObservableObject {
    @Published var query: String
    @Published var searchInSubredditOrUserName: String?
    @Published var searchInMultiReddit: String?
    @Published var searchInThingType: Int
    
    init(query: String, searchInSubredditOrUserName: String?, searchInMultiReddit: String?, searchInThingType: Int) {
        self.query = query
        self.searchInSubredditOrUserName = searchInSubredditOrUserName
        self.searchInMultiReddit = searchInMultiReddit
        self.searchInThingType = searchInThingType
    }
}
