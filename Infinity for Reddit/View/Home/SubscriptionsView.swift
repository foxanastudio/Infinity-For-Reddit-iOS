//
//  SubscriptionsView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-03.
//

import SwiftUI
import Swinject
import GRDB
import Alamofire

struct SubscriptionsView: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    
    @StateObject var subscriptionListingViewModel: SubscriptionListingViewModel

    @State private var selectedOption = 0
    
    private let customOnTapForSearchInThing: ((SearchInThing) -> Void)?
    
    init(customOnTapForSearchInThing: ((SearchInThing) -> Void)? = nil) {
        _subscriptionListingViewModel = StateObject(
            wrappedValue: SubscriptionListingViewModel(
                subscriptionListingRepository: SubscriptionListingRepository()
            )
        )
        self.customOnTapForSearchInThing = customOnTapForSearchInThing
    }

    var body: some View {
        VStack(spacing: 0) {
            SegmentedPicker(selectedValue: $selectedOption, values: ["Subreddits", "Users", "Custom Feed"])
                .padding(4)
            
            TabView(selection: $selectedOption) {
                if let customOnTapForSearchInThing = customOnTapForSearchInThing {
                    SubscribedSubredditListingView(subscriptionListingViewModel: subscriptionListingViewModel) { subscribedSubredditData in
                        customOnTapForSearchInThing(SearchInThing.subreddit(subscribedSubredditData))
                    }
                    .tag(0)
                } else {
                    SubscribedSubredditListingView(subscriptionListingViewModel: subscriptionListingViewModel)
                }
                
                UsersView(subscriptionListingViewModel: subscriptionListingViewModel, customOnTapForSearchInThing: customOnTapForSearchInThing)
                    .tag(1)
                
                CustomFeedView(subscriptionListingViewModel: subscriptionListingViewModel, customOnTapForSearchInThing: customOnTapForSearchInThing)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .rootViewBackground()
        .task {
            await subscriptionListingViewModel.loadSubscriptionsOnline()
            await subscriptionListingViewModel.loadMyCustomFeedsOnline()
        }
    }

    struct UsersView: View {
        @EnvironmentObject var navigationManager: NavigationManager
        @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
        
        let customOnTapForSearchInThing: ((SearchInThing) -> Void)?
        
        var body: some View {
            Group {
                if subscriptionListingViewModel.userSubscriptions.isEmpty {
                    if subscriptionListingViewModel.isLoadingSubscriptions {
                        ProgressIndicator()
                    } else {
                        Text("No subscribed users")
                            .primaryText()
                    }
                } else {
                    List {
                        if !subscriptionListingViewModel.favoriteUserSubscriptions.isEmpty {
                            Section(header: Text("Favorite").listSectionHeader()) {
                                ForEach(subscriptionListingViewModel.favoriteUserSubscriptions, id: \.identityInView) { subscription in
                                    SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                        if let customOnTapForSearchInThing = customOnTapForSearchInThing {
                                            customOnTapForSearchInThing(SearchInThing.user(subscription))
                                        } else {
                                            navigationManager.path.append(AppNavigation.userDetails(username: subscription.name))
                                        }
                                    }) {
                                        subscription.isFavorite.toggle()
                                        Task {
                                            await subscriptionListingViewModel.toggleFavoriteUser(subscription)
                                        }
                                    }
                                    .listPlainItemNoInsets()
                                }
                            }
                            .listPlainItem()
                        }
                        
                        Section(header: Text("All").listSectionHeader()) {
                            ForEach(subscriptionListingViewModel.userSubscriptions, id: \.identityInView) { subscription in
                                SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                    if let customOnTapForSearchInThing = customOnTapForSearchInThing {
                                        customOnTapForSearchInThing(SearchInThing.user(subscription))
                                    } else {
                                        navigationManager.path.append(AppNavigation.userDetails(username: subscription.name))
                                    }
                                }) {
                                    subscription.isFavorite.toggle()
                                    Task {
                                        await subscriptionListingViewModel.toggleFavoriteUser(subscription)
                                    }
                                }
                                .listPlainItemNoInsets()
                            }
                        }
                        .listPlainItem()
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .themedList()
                }
            }
        }
    }

    struct CustomFeedView: View {
        @EnvironmentObject var navigationManager: NavigationManager
        @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
        
        let customOnTapForSearchInThing: ((SearchInThing) -> Void)?
        
        var body: some View {
            Group {
                if subscriptionListingViewModel.myCustomFeeds.isEmpty {
                    if subscriptionListingViewModel.isLoadingMyCustomFeeds {
                        ProgressIndicator()
                    } else {
                        Text("No custom feeds")
                            .primaryText()
                    }
                } else {
                    List {
                        if !subscriptionListingViewModel.favoriteMyCustomFeeds.isEmpty {
                            Section(header: Text("Favorite").listSectionHeader()) {
                                ForEach(subscriptionListingViewModel.favoriteMyCustomFeeds, id: \.identityInView) { customFeed in
                                    SubscriptionItemView(text: customFeed.displayName, iconUrl: customFeed.iconUrl, isFavorite: customFeed.isFavorite, action: {
                                        if let customOnTapForSearchInThing = customOnTapForSearchInThing {
                                            customOnTapForSearchInThing(SearchInThing.customFeed(customFeed))
                                        } else {
                                            navigationManager.path.append(AppNavigation.customFeed(myCustomFeed: customFeed))
                                        }
                                    }) {
                                        customFeed.isFavorite.toggle()
                                        Task {
                                            await subscriptionListingViewModel.toggleFavoriteCustomFeed(customFeed)
                                        }
                                    }
                                    .listPlainItemNoInsets()
                                }
                            }
                            .listPlainItem()
                        }
                        
                        Section(header: Text("All").listSectionHeader()) {
                            ForEach(subscriptionListingViewModel.myCustomFeeds, id: \.identityInView) { customFeed in
                                SubscriptionItemView(text: customFeed.displayName, iconUrl: customFeed.iconUrl, isFavorite: customFeed.isFavorite, action: {
                                    if let customOnTapForSearchInThing = customOnTapForSearchInThing {
                                        customOnTapForSearchInThing(SearchInThing.customFeed(customFeed))
                                    } else {
                                        navigationManager.path.append(AppNavigation.customFeed(myCustomFeed: customFeed))
                                    }
                                }) {
                                    customFeed.isFavorite.toggle()
                                    Task {
                                        await subscriptionListingViewModel.toggleFavoriteCustomFeed(customFeed)
                                    }
                                }
                                .listPlainItemNoInsets()
                            }
                        }
                        .listPlainItem()
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .themedList()
                }
            }
        }
    }
}
