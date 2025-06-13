//
//  CustomFeedDetailsView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-27.
//

import SwiftUI

struct CustomFeedDetailsView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @StateObject private var customFeedDetailsViewModel: CustomFeedDetailsViewModel
    
    init(myCustomFeed: MyCustomFeed) {
        _customFeedDetailsViewModel = StateObject(
            wrappedValue: CustomFeedDetailsViewModel(
                myCustomFeed: myCustomFeed,
                customFeedDetailsRepository: CustomFeedDetailsRepository()
            )
        )
    }
    
    var body: some View {
        PostListingView(
            account: accountViewModel.account,
            postListingMetadata: PostListingMetadata(
                postListingType: .multireddit,
                pathComponents: ["multipath": customFeedDetailsViewModel.myCustomFeed.path],
                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                queries: nil,
                params: nil
            )
        )
        .id(accountViewModel.account.username)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar(customFeedDetailsViewModel.myCustomFeed.displayName, 1.0)
    }
}
