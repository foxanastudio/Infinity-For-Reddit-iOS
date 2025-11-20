//
//  AnonymousSubscriptionsView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-08.
//

import SwiftUI
import Swinject
import GRDB
import Alamofire

struct AnonymousSubscriptionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @StateObject var anonymousSubscriptionListingViewModel: AnonymousSubscriptionListingViewModel

    @State private var selectedOption = 0
    @State private var navigationBarMenuKey: UUID?
    
    init(subscriptionSelectionMode: SubscriptionSelectionMode = .noSelection) {
        _anonymousSubscriptionListingViewModel = StateObject(
            wrappedValue: AnonymousSubscriptionListingViewModel(
                subscriptionSelectionMode: subscriptionSelectionMode,
                anonymousSubscriptionListingRepository: AnonymousSubscriptionListingRepository()
            )
        )
    }

    var body: some View {
        RootView {
            VStack(spacing: 0) {
                switch anonymousSubscriptionListingViewModel.subscriptionSelectionMode {
                case .subredditAndUserInCustomFeed:
                    SegmentedPicker(
                        selectedValue: $selectedOption,
                        values: ["Subreddits", "Users"]
                    )
                    .padding(4)
                default:
                    SegmentedPicker(
                        selectedValue: $selectedOption,
                        values: ["Subreddits", "Users", "Custom Feed"]
                    )
                    .padding(4)
                }
                
                TabView(selection: $selectedOption) {
                    Group {
                        switch anonymousSubscriptionListingViewModel.subscriptionSelectionMode {
                        case .noSelection:
                            AnonymousSubscribedSubredditListingView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                                .tag(0)
                            
                            AnonymousSubscribedUserListingView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                                .tag(1)
                            
                            AnonymousCustomFeedView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                                .tag(2)
                        case .searchInThing(let onSelectSearchInThing):
                            AnonymousSubscribedSubredditListingView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel) { subscribedSubredditData in
                                onSelectSearchInThing(SearchInThing.subreddit(subscribedSubredditData))
                            }
                            .tag(0)
                            
                            AnonymousSubscribedUserListingView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel) { subscribedUserData in
                                onSelectSearchInThing(SearchInThing.user(subscribedUserData))
                            }
                            .tag(1)
                            
                            AnonymousCustomFeedView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                                .tag(2)
                        case .subredditAndUserInCustomFeed:
                            AnonymousSubscribedSubredditListingMultiSelectionView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                                .tag(0)
                            
                            AnonymousSubscribedUserListingMultiSelectionView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                                .tag(1)
                        }
                    }
                    .toolbar(.hidden, for: .tabBar)
                }
                
                if case .subredditAndUserInCustomFeed(_, let onSelectMultipleSubscriptions) = anonymousSubscriptionListingViewModel.subscriptionSelectionMode {
                    Button {
                        onSelectMultipleSubscriptions(anonymousSubscriptionListingViewModel.getSelectedSubredditsAndUsersInCustomFeed())
                        dismiss()
                    } label: {
                        HStack {
                            Text("Done")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(16)
                    .filledButton()
                }
            }
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Create Custom Feed") {
                    navigationManager.append(AppNavigation.createCustomFeed)
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

    struct AnonymousCustomFeedView: View {
        @EnvironmentObject var navigationManager: NavigationManager
        @ObservedObject var anonymousSubscriptionListingViewModel: AnonymousSubscriptionListingViewModel
        
        var body: some View {
            Group {
                if anonymousSubscriptionListingViewModel.myCustomFeeds.isEmpty {
                    Text("No custom feeds")
                        .primaryText()
                } else {
                    List {
                        if !anonymousSubscriptionListingViewModel.favoriteMyCustomFeeds.isEmpty {
                            CustomListSection("Favorite") {
                                ForEach(anonymousSubscriptionListingViewModel.favoriteMyCustomFeeds, id: \.identityInView) { customFeed in
                                    SubscriptionItemView(text: customFeed.displayName, iconUrl: customFeed.iconUrl, isFavorite: customFeed.isFavorite, action: {
                                        navigationManager.append(AppNavigation.customFeed(myCustomFeed: customFeed))
                                    }) {
                                        customFeed.isFavorite.toggle()
                                        anonymousSubscriptionListingViewModel.toggleFavoriteCustomFeed(customFeed)
                                    }
                                    .listPlainItemNoInsets()
                                }
                            }
                        }
                        
                        CustomListSection("All") {
                            ForEach(anonymousSubscriptionListingViewModel.myCustomFeeds, id: \.identityInView) { customFeed in
                                SubscriptionItemView(text: customFeed.displayName, iconUrl: customFeed.iconUrl, isFavorite: customFeed.isFavorite, action: {
                                    navigationManager.append(AppNavigation.customFeed(myCustomFeed: customFeed))
                                }) {
                                    customFeed.isFavorite.toggle()
                                    anonymousSubscriptionListingViewModel.toggleFavoriteCustomFeed(customFeed)
                                }
                                .listPlainItemNoInsets()
                            }
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .themedList()
                }
            }
        }
    }
}
