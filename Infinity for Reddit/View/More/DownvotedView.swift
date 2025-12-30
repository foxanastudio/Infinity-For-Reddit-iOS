//
// DownvotedView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct DownvotedView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    var body: some View {
        Group {
            if accountViewModel.account.isAnonymous() {
                HistoryPostListingView(historyPostListingMetadata: HistoryPostListingMetadata(
                    historyPostListingType: .downvoted
                ))
            } else {
                PostListingView(
                    postListingMetadata: PostListingMetadata(
                        postListingType: .user(username: accountViewModel.account.username, userWhere: .downvoted),
                        pathComponents: ["username": accountViewModel.account.username, "where": UserWhere.downvoted.rawValue],
                        headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                        queries: nil,
                        params: nil
                    )
                )
            }
        }
        .id(accountViewModel.account.username)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Downvoted")
    }
}

