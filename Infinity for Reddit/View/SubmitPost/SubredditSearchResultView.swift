//
// SubredditSearchResultView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-09-06
        
import SwiftUI

struct SubredditSearchResultView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var subredditChooseViewModel: SubredditChooseViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var searchResultsViewModel: SearchResultsViewModel
    @State private var selectedOption = 0
    
    init(query: String, searchInSubredditOrUserName: String?, searchInMultiReddit: String?, searchInThingType: Int) {
        _searchResultsViewModel = StateObject(wrappedValue: SearchResultsViewModel(query: query, searchInSubredditOrUserName: searchInSubredditOrUserName, searchInMultiReddit: searchInMultiReddit, searchInThingType: searchInThingType))
    }
    
    var body: some View {
        VStack {
            SubredditListingView(account: accountViewModel.account, query: searchResultsViewModel.query) { subreddit in
                subredditChooseViewModel.selectedSubreddit = SubscribedSubredditData.fromSubreddit(subreddit, username: accountViewModel.account.username)
                if navigationManager.path.count >= 3 {
                    navigationManager.path.removeLast(3)
                }
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Subreddits")
        .id(accountViewModel.account.username)
        .toolbar {
            NavigationBarMenu()
        }
    }
}

