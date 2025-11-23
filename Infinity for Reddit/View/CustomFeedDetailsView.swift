//
//  CustomFeedDetailsView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-27.
//

import SwiftUI

struct CustomFeedDetailsView: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @StateObject private var customFeedDetailsViewModel: CustomFeedDetailsViewModel
    
    @State private var navigationBarMenuKey: UUID?
    
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
            postListingMetadata: PostListingMetadata(
                postListingType: customFeedDetailsViewModel.myCustomFeed.owner == Account.ANONYMOUS_ACCOUNT.username ? .anonymousCustomFeed(myCustomFeed: customFeedDetailsViewModel.myCustomFeed, concatenatedSubscriptions: nil) : .customFeed(path: customFeedDetailsViewModel.myCustomFeed.path),
                pathComponents: ["multipath": customFeedDetailsViewModel.myCustomFeed.path],
                headers: APIUtils.getOAuthHeader(accessToken: accountViewModel.account.accessToken ?? ""),
                queries: nil,
                params: nil
            )
        )
        .id(accountViewModel.account.username)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar(customFeedDetailsViewModel.myCustomFeed.displayName)
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Edit Custom Feed") {
                    navigationManager.append(AppNavigation.editCustomFeed(myCustomFeed: customFeedDetailsViewModel.myCustomFeed))
                }
            ])
        }
        .onDisappear {
            guard let navigationBarMenuKey else {
                return
            }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
    }
}
