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
        VStack(spacing: 0) {
            SegmentedPicker(selectedValue: $selectedOption, values: accountViewModel.account.isAnonymous() ? ["Posts"] : ["Posts", "Comments"])
                .padding(4)
            
            TabView(selection: $selectedOption) {
                Group {
                    if accountViewModel.account.isAnonymous() {
                        HistoryPostListingView(
                            historyPostListingMetadata: HistoryPostListingMetadata(
                                historyPostListingType: .saved
                            ),
                            handleToolbarMenu: false
                        )
                    } else {
                        PostListingView(
                            postListingMetadata: PostListingMetadata(
                                postListingType: .user(username: accountViewModel.account.username, userWhere: .saved),
                                pathComponents: ["username": accountViewModel.account.username, "where": UserWhere.saved.rawValue],
                                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                                queries: nil,
                                params: nil
                            ),
                            handleToolbarMenu: false
                        )
                    }
                }
                .tag(0)
                
                if accountViewModel.account.isAnonymous() {
                    CommentListingView(
                        commentListingMetadata: CommentListingMetadata(
                            commentListingType:.userSaved,
                            pathComponents: ["username": "\(accountViewModel.account.username)"],
                            queries: nil
                        )
                    )
                    .tag(1)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Saved")
        .id(accountViewModel.account.username)
        .toolbar {
            NavigationBarMenu()
        }
    }
}

