//
//  FilteredPostsView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-02.
//

import SwiftUI

struct FilteredPostsView: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var navigationBarMenuManager: NavigationBarMenuManager
    
    @StateObject private var filteredPostsViewModel: FilteredPostsViewModel
    
    @State private var showCustomizePostFilterSheet: Bool = false
    @State private var navigationBarMenuKey: UUID?
    
    let postListingMetadata: PostListingMetadata
    
    init(postListingMetadata: PostListingMetadata, postFilter: PostFilter) {
        self.postListingMetadata = postListingMetadata
        _filteredPostsViewModel = StateObject(
            wrappedValue: .init(postFilter: postFilter)
        )
    }
    
    var body: some View {
        PostListingView(
            account: accountViewModel.account,
            postListingMetadata: postListingMetadata,
            handleToolbarMenu: false,
            showFilterPostsOption: false
        )
        .addTitleToInlineNavigationBar("Filtered Posts")
        .themedNavigationBar()
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
                filteredPostsViewModel.postFilter,
                showInSheet: true
            ) { postFilter in
                print(postFilter)
                filteredPostsViewModel.postFilter = postFilter
            }
        }
    }
}
