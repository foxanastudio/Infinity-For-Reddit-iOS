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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @StateObject var anonymousSubscriptionListingViewModel: AnonymousSubscriptionListingViewModel

    @State private var selectedOption = 0
    
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
                SegmentedPicker(selectedValue: $selectedOption, values: ["Subreddits", "Users", "Custom Feed"])
                    .padding(4)
                
                TabView(selection: $selectedOption) {
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
                        EmptyView()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
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
