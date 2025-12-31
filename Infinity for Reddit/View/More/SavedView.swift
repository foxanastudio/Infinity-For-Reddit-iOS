//
// SavedView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct SavedView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @State private var selectedOption = 0
    
    var body: some View {
        RootView {
            VStack(spacing: 0) {
                if !accountViewModel.account.isAnonymous() {
                    SegmentedPicker(selectedValue: $selectedOption, values: ["Posts", "Comments"])
                        .padding(4)
                }
                
                TabView(selection: $selectedOption) {
                    Group {
                        if accountViewModel.account.isAnonymous() {
                            HistoryPostListingView(
                                historyPostListingMetadata: HistoryPostListingMetadata(
                                    historyPostListingType: .saved
                                ),
                                handleToolbarMenu: false
                            )
                            .tag(0)
                        } else {
                            PostListingView(
                                postListingMetadata: PostListingMetadata(
                                    postListingType: .user(username: accountViewModel.account.username, userWhere: .saved),
                                    pathComponents: ["username": accountViewModel.account.username, "where": UserWhere.saved.rawValue],
                                    headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                    queries: nil,
                                    params: nil
                                ),
                                isPresented: true,
                                handleToolbarMenu: false
                            )
                            .tag(0)
                        }
                        
                        if !accountViewModel.account.isAnonymous() {
                            CommentListingView(
                                commentListingMetadata: CommentListingMetadata(
                                    commentListingType:.userSaved,
                                    pathComponents: ["username": "\(accountViewModel.account.username)"],
                                    queries: nil
                                ),
                                isPresented: true
                            )
                            .tag(1)
                        }
                    }
                    .toolbar(.hidden, for: .tabBar)
                }
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Saved")
        .id(accountViewModel.account.username)
        .toolbar {
            NavigationBarMenu()
        }
    }
}

