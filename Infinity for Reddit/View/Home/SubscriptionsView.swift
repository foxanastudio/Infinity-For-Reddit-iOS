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
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    
    @StateObject var subscriptionListingViewModel: SubscriptionListingViewModel

    @State private var selectedOption = 0
    @State private var navigationBarMenuKey: UUID?
    
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
        RootView {
            VStack(spacing: 0) {
                SegmentedPicker(selectedValue: $selectedOption, values: ["Subreddits", "Users", "Custom Feed"])
                    .padding(4)
                
                TabView(selection: $selectedOption) {
                    Group {
                        if let customOnTapForSearchInThing = customOnTapForSearchInThing {
                            SubscribedSubredditListingView(subscriptionListingViewModel: subscriptionListingViewModel) { subscribedSubredditData in
                                customOnTapForSearchInThing(SearchInThing.subreddit(subscribedSubredditData))
                            }
                            .tag(0)
                        } else {
                            SubscribedSubredditListingView(subscriptionListingViewModel: subscriptionListingViewModel)
                                .tag(0)
                        }
                        
                        UsersView(subscriptionListingViewModel: subscriptionListingViewModel, customOnTapForSearchInThing: customOnTapForSearchInThing)
                            .tag(1)
                        
                        CustomFeedView(subscriptionListingViewModel: subscriptionListingViewModel, customOnTapForSearchInThing: customOnTapForSearchInThing)
                            .tag(2)
                    }
                    .toolbar(.hidden, for: .tabBar)
                }
            }
        }
        .task(id: subscriptionListingViewModel.subscriptionAndCustomFeedLoadingTaskFlag) {
            await subscriptionListingViewModel.loadSubscriptionsOnline()
            await subscriptionListingViewModel.loadMyCustomFeedsOnline()
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Refresh") {
                    subscriptionListingViewModel.refreshSubscriptions()
                }
            ])
        }
        .onDisappear {
            guard let navigationBarMenuKey else { return }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
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
                            CustomListSection("Favorite") {
                                ForEach(subscriptionListingViewModel.favoriteUserSubscriptions, id: \.identityInView) { subscription in
                                    SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                        if let customOnTapForSearchInThing = customOnTapForSearchInThing {
                                            customOnTapForSearchInThing(SearchInThing.user(subscription))
                                        } else {
                                            navigationManager.append(AppNavigation.userDetails(username: subscription.name))
                                        }
                                    }) {
                                        subscription.isFavorite.toggle()
                                        Task {
                                            await subscriptionListingViewModel.toggleFavoriteUser(subscription)
                                        }
                                    }
                                    .listPlainItemNoInsets()
                                    .applyIf(customOnTapForSearchInThing == nil) {
                                        $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                Task {
                                                    await subscriptionListingViewModel.unfollowUser(subscription)
                                                }
                                            } label: {
                                                Text("Unfollow")
                                                    .foregroundStyle(.white)
                                            }
                                            .tint(.red)
                                        }
                                    }
                                }
                            }
                        }
                        
                        CustomListSection("All") {
                            ForEach(subscriptionListingViewModel.userSubscriptions, id: \.identityInView) { subscription in
                                SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                    if let customOnTapForSearchInThing = customOnTapForSearchInThing {
                                        customOnTapForSearchInThing(SearchInThing.user(subscription))
                                    } else {
                                        navigationManager.append(AppNavigation.userDetails(username: subscription.name))
                                    }
                                }) {
                                    subscription.isFavorite.toggle()
                                    Task {
                                        await subscriptionListingViewModel.toggleFavoriteUser(subscription)
                                    }
                                }
                                .listPlainItemNoInsets()
                                .applyIf(customOnTapForSearchInThing == nil) {
                                    $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            Task {
                                                await subscriptionListingViewModel.unfollowUser(subscription)
                                            }
                                        } label: {
                                            Text("Unfollow")
                                                .foregroundStyle(.white)
                                        }
                                        .tint(.red)
                                    }
                                }
                            }
                        }
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
                            CustomListSection("Favorite") {
                                ForEach(subscriptionListingViewModel.favoriteMyCustomFeeds, id: \.identityInView) { customFeed in
                                    SubscriptionItemView(text: customFeed.displayName, iconUrl: customFeed.iconUrl, isFavorite: customFeed.isFavorite, action: {
                                        if let customOnTapForSearchInThing = customOnTapForSearchInThing {
                                            customOnTapForSearchInThing(SearchInThing.customFeed(customFeed))
                                        } else {
                                            navigationManager.append(AppNavigation.customFeed(myCustomFeed: customFeed))
                                        }
                                    }) {
                                        customFeed.isFavorite.toggle()
                                        Task {
                                            await subscriptionListingViewModel.toggleFavoriteCustomFeed(customFeed)
                                        }
                                    }
                                    .listPlainItemNoInsets()
                                    .applyIf(customOnTapForSearchInThing == nil) {
                                        $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                Task {
                                                    await subscriptionListingViewModel.deleteCustomFeed(customFeed)
                                                }
                                            } label: {
                                                Text("Delete")
                                                    .foregroundStyle(.white)
                                            }
                                            .tint(.red)
                                        }
                                    }
                                }
                            }
                        }
                        
                        CustomListSection("All") {
                            ForEach(subscriptionListingViewModel.myCustomFeeds, id: \.identityInView) { customFeed in
                                SubscriptionItemView(text: customFeed.displayName, iconUrl: customFeed.iconUrl, isFavorite: customFeed.isFavorite, action: {
                                    if let customOnTapForSearchInThing = customOnTapForSearchInThing {
                                        customOnTapForSearchInThing(SearchInThing.customFeed(customFeed))
                                    } else {
                                        navigationManager.append(AppNavigation.customFeed(myCustomFeed: customFeed))
                                    }
                                }) {
                                    customFeed.isFavorite.toggle()
                                    Task {
                                        await subscriptionListingViewModel.toggleFavoriteCustomFeed(customFeed)
                                    }
                                }
                                .listPlainItemNoInsets()
                                .applyIf(customOnTapForSearchInThing == nil) {
                                    $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            Task {
                                                await subscriptionListingViewModel.deleteCustomFeed(customFeed)
                                            }
                                        } label: {
                                            Text("Delete")
                                                .foregroundStyle(.white)
                                        }
                                        .tint(.red)
                                    }
                                }
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
