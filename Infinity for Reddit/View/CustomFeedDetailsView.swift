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
    
    init(customFeed: CustomFeedWrapper) {
        _customFeedDetailsViewModel = StateObject(
            wrappedValue: CustomFeedDetailsViewModel(
                customFeed: customFeed,
                customFeedDetailsRepository: CustomFeedDetailsRepository()
            )
        )
    }
    
    var body: some View {
        PostListingView(
            postListingMetadata: PostListingMetadata(
                postListingType: postListingType,
                pathComponents: pathComponents,
                headers: nil,
                queries: nil,
                params: nil
            )
        )
        .id(accountViewModel.account.username)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar(customFeedDetailsViewModel.customFeed.displayName)
        .onAppear {
            setupMenu()
        }
        .onDisappear {
            guard let navigationBarMenuKey else {
                return
            }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
    }
    
    var postListingType: PostListingType {
        if accountViewModel.account.isAnonymous(), case .myCustomFeed(let myCustomFeed) = customFeedDetailsViewModel.customFeed {
            return myCustomFeed.owner == Account.ANONYMOUS_ACCOUNT.username
            ? .anonymousCustomFeed(myCustomFeed: myCustomFeed, concatenatedSubscriptions: nil)
            : .customFeed(path: myCustomFeed.path)
        }
        return .customFeed(path: customFeedDetailsViewModel.customFeed.path)
    }
    
    var pathComponents: [String: String] {
        return ["multipath": customFeedDetailsViewModel.customFeed.path]
    }
    
    func setupMenu() {
        if let key = navigationBarMenuKey {
            navigationBarMenuManager.pop(key: key)
        }
        var navigationBarMenuItems: [NavigationBarMenuItem] = []
        switch customFeedDetailsViewModel.customFeed {
        case .myCustomFeed:
            navigationBarMenuItems.append(NavigationBarMenuItem(title: "Edit Custom Feed") {
                navigationManager.append(AppNavigation.editCustomFeed(customFeedToEdit: customFeedDetailsViewModel.customFeed))
            })
        case .path(let path):
            navigationBarMenuItems.append(NavigationBarMenuItem(title: "Copy Custom Feed") {
                navigationManager.append(AppNavigation.copyCustomFeed(path: path))
            })
        }
        navigationBarMenuKey = navigationBarMenuManager.push(navigationBarMenuItems)
    }
}
