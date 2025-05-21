//
//  SubredditListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-19.
//

import SwiftUI

struct SubredditListingView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var navigationManager: NavigationManager
    
    @StateObject var subredditListingViewModel: SubredditListingViewModel
    private let account: Account
    
    init(account: Account, query: String) {
        self.account = account
        
        _subredditListingViewModel = StateObject(
            wrappedValue: SubredditListingViewModel(
                query: query,
                subredditListingRepository: SubredditListingRepository()
            )
        )
    }
    
    var body: some View {
        Text("Subreddit Listing View")
            .task {
                await subredditListingViewModel.initialLoadSubreddits()
            }
    }
}
