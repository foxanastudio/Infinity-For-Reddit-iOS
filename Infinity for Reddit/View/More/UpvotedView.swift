//
// UpvotedView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct UpvotedView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    var body: some View {
        PostListingView(
            account: accountViewModel.account,
            postListingMetadata: PostListingMetadata(
                postListingType: .user(username: accountViewModel.account.username, userWhere: .upvoted),
                pathComponents: ["username": accountViewModel.account.username, "where": UserWhere.upvoted.rawValue],
                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                queries: nil,
                params: nil
            )
        )
        .id(accountViewModel.account.username)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Upvoted", 1.0)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    
                }) {
                    Text("leading")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    
                }) {
                    Text("huh")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    
                }) {
                    Text("faf")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    
                }) {
                    Text("faasdfasdff")
                }
            }
        }
    }
}

