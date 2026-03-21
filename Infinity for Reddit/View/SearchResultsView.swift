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
    @StateObject private var subredditListingViewModel: SubredditListingViewModel
    @StateObject private var userListingViewModel: UserListingViewModel
    
    @State private var selectedTab: Int
    
    init(query: String,
         searchInSubredditOrUserName: String?,
         searchInMultiReddit: String?,
         searchInThingType: SearchInThingType,
         searchResultTab: Int
    ) {
        self.selectedTab = searchResultTab
        _searchResultsViewModel = StateObject(wrappedValue: SearchResultsViewModel(query: query, searchInSubredditOrUserName: searchInSubredditOrUserName, searchInMultiReddit: searchInMultiReddit, searchInThingType: searchInThingType))
        _subredditListingViewModel = StateObject(
            wrappedValue: SubredditListingViewModel(
                query: query,
                thingSelectionMode: .noSelection,
                subredditListingRepository: SubredditListingRepository()
            )
        )
        _userListingViewModel = StateObject(
            wrappedValue: UserListingViewModel(
                query: query,
                thingSelectionMode: .noSelection,
                userListingRepository: UserListingRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            VStack(spacing: 0) {
                SegmentedPicker(selectedValue: $selectedTab, values: ["Posts", "Subreddits", "Users"])
                    .padding(4)
                
                ZStack {
                    PostListingView(
                        postListingMetadata: PostListingMetadata(
                            postListingType: PostListingType.search(
                                query: searchResultsViewModel.query,
                                searchInSubredditOrUserName: searchResultsViewModel.searchInSubredditOrUserName,
                                searchInMultiReddit: searchResultsViewModel.searchInMultiReddit,
                                searchInThingType: searchResultsViewModel.searchInThingType
                            ),
                            queries: ["q": searchResultsViewModel.query, "type": "link"],
                            params: nil
                        ),
                        handleToolbarMenu: false,
                        isPresented: selectedTab == 0
                    )
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 0)
                    
                    SubredditListingView(
                        account: accountViewModel.account,
                        subredditListingViewModel: subredditListingViewModel,
                        isPresented: selectedTab == 1
                    )
                    .opacity(selectedTab == 1 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 1)
                    
                    UserListingView(
                        account: accountViewModel.account,
                        userListingViewModel: userListingViewModel,
                        isPresented: selectedTab == 2
                    )
                    .opacity(selectedTab == 2 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 2)
                }
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar(searchResultsViewModel.query)
        .toolbar {
            NavigationBarMenu()
        }
    }
}
