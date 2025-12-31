//
//  PopularOrAllView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-16.
//

import SwiftUI

struct PopularOrAllView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    let subredditName: String
    
    var body: some View {
        PostListingView(
            postListingMetadata:PostListingMetadata(
                postListingType:.subreddit(subredditName: subredditName),
                pathComponents: ["subreddit": subredditName],
                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                queries: nil,
                params: nil
            ),
            isPresented: true
        )
        .id(accountViewModel.account.username)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar(subredditName.capitalized, 1.0)
    }
}
