//
//  FilteredHistoryPostsView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-03.
//

import SwiftUI

struct FilteredHistoryPostsView: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var navigationBarMenuManager: NavigationBarMenuManager
    
    @StateObject private var filteredHistoryPostsViewModel: FilteredHistoryPostsViewModel
    
    @State private var showCustomizePostFilterSheet: Bool = false
    @State private var navigationBarMenuKey: UUID?
    
    let historyPostListingMetadata: HistoryPostListingMetadata
    
    init(historyPostListingMetadata: HistoryPostListingMetadata, postFilter: PostFilter) {
        self.historyPostListingMetadata = historyPostListingMetadata
        _filteredHistoryPostsViewModel = StateObject(
            wrappedValue: .init(postFilter: postFilter)
        )
    }
    
    var body: some View {
        HistoryPostListingView(
            historyPostListingMetadata: historyPostListingMetadata,
            externalPostFilter: filteredHistoryPostsViewModel.postFilter,
            handleToolbarMenu: false,
            showFilterPostsOption: false
        )
        .addTitleToInlineNavigationBar("Filtered Posts")
        .themedNavigationBar()
        .id(filteredHistoryPostsViewModel.postFilter)
        .toolbar {
            NavigationBarMenu()
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Filter Posts") {
                    showCustomizePostFilterSheet = true
                }
            ])
        }
        .onDisappear {
            guard let navigationBarMenuKey else { return }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
        .sheet(isPresented: $showCustomizePostFilterSheet) {
            CustomizePostFilterView(
                filteredHistoryPostsViewModel.postFilter,
                showInSheet: true
            ) { postFilter in
                print(postFilter)
                filteredHistoryPostsViewModel.postFilter = postFilter
            }
        }
    }
}
