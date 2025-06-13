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
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    var body: some View {
        PostListingView(
            account: accountViewModel.account,
            postListingMetadata: PostListingMetadata(
                postListingType: .user(username: accountViewModel.account.username, userWhere: .saved),
                pathComponents: ["username": accountViewModel.account.username, "where": UserWhere.saved.rawValue],
                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                queries: nil,
                params: nil
            )
        )
        .id(accountViewModel.account.username)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Saved", 1.0)
    }
}

