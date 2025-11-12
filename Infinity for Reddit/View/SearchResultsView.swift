//
//  SearchResultsView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-18.
//

import SwiftUI

struct SearchResultsView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    @StateObject private var searchResultsViewModel: SearchResultsViewModel
    @State private var selectedOption: Int
    
    init(query: String,
         searchInSubredditOrUserName: String?,
         searchInMultiReddit: String?,
         searchInThingType: SearchInThingType,
         searchResultTab: Int
    ) {
        self.selectedOption = searchResultTab
        _searchResultsViewModel = StateObject(wrappedValue: SearchResultsViewModel(query: query, searchInSubredditOrUserName: searchInSubredditOrUserName, searchInMultiReddit: searchInMultiReddit, searchInThingType: searchInThingType))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SegmentedPicker(selectedValue: $selectedOption, values: ["Posts", "Subreddits", "Users"])
                .padding(4)
            
            TabView(selection: $selectedOption) {
                PostListingView(postListingMetadata: PostListingMetadata(
                    postListingType: PostListingType.search(
                        query: searchResultsViewModel.query,
                        searchInSubredditOrUserName: searchResultsViewModel.searchInSubredditOrUserName,
                        searchInMultiReddit: searchResultsViewModel.searchInMultiReddit,
                        searchInThingType: searchResultsViewModel.searchInThingType
                    ),
                    headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                    queries: ["q": searchResultsViewModel.query, "type": "link"],
                    params: nil
                ), handleToolbarMenu: false)
                .tag(0)
                
                SubredditListingView(account: accountViewModel.account, query: searchResultsViewModel.query)
                    .tag(1)
                
                UserListingView(account: accountViewModel.account, query: searchResultsViewModel.query)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar(searchResultsViewModel.query)
        .id(accountViewModel.account.username)
        .toolbar {
            NavigationBarMenu()
        }
    }
}
