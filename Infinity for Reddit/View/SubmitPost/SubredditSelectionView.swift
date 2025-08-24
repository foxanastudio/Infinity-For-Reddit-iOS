
//
// SubredditSelectionView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21
        
import SwiftUI
import Swinject
import GRDB
import Alamofire

struct SubredditSelectionView: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @StateObject var subscriptionListingViewModel: SubscriptionListingViewModel

    @State private var selectedOption = 0
    
    init() {
        _subscriptionListingViewModel = StateObject(
            wrappedValue: SubscriptionListingViewModel(
                subscriptionListingRepository: SubscriptionListingRepository()
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            SegmentedPicker(selectedValue: $selectedOption, values: ["Subreddits", "Users", "Custom Feed"])
                .padding(4)
            
            TabView(selection: $selectedOption) {
                SubredditsView(subscriptionListingViewModel: subscriptionListingViewModel)
                    .tag(0)
                
                UsersView(subscriptionListingViewModel: subscriptionListingViewModel)
                    .tag(1)
                
                CustomFeedView(subscriptionListingViewModel: subscriptionListingViewModel)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Select a Subreddit")
        .task {
            await subscriptionListingViewModel.loadSubscriptionsOnline()
            await subscriptionListingViewModel.loadMyCustomFeedsOnline()
        }
    }
    
    struct SubredditsView: View {
        @EnvironmentObject var navigationManager: NavigationManager
        @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
        @Environment(\.dismiss) private var dismiss
        @EnvironmentObject private var subredditChooseViewModel: SubredditChooseViewModel
        
        var body: some View {
            Group {
                if subscriptionListingViewModel.subredditSubscriptions.isEmpty {
                    if subscriptionListingViewModel.isLoadingSubscriptions {
                        ProgressIndicator()
                    } else {
                        Text("No subscribed subreddits")
                            .primaryText()
                    }
                } else {
                    List {
                        if !subscriptionListingViewModel.favoriteSubredditSubscriptions.isEmpty {
                            Section(header: Text("Favorite").listSectionHeader()) {
                                ForEach(subscriptionListingViewModel.favoriteSubredditSubscriptions, id: \.identityInView) { subscription in
                                    SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                        subredditChooseViewModel.selectedSubreddit = subscription
                                        dismiss()
                                    }){
                                        subscription.isFavorite.toggle()
                                        Task {
                                            await subscriptionListingViewModel.toggleFavoriteSubreddit(subscription)
                                        }
                                    }
                                    .listPlainItemNoInsets()
                                }
                            }
                            .listPlainItem()
                        }
                        
                        Section(header: Text("All").listSectionHeader()) {
                            ForEach(subscriptionListingViewModel.subredditSubscriptions, id: \.identityInView) { subscription in
                                SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                    subredditChooseViewModel.selectedSubreddit = subscription
                                    dismiss()
                                }) {
                                    subscription.isFavorite.toggle()
                                    Task {
                                        await subscriptionListingViewModel.toggleFavoriteSubreddit(subscription)
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

    struct UsersView: View {
        @EnvironmentObject var navigationManager: NavigationManager
        @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
        
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
                                        navigationManager.path.append(AppNavigation.userDetails(username: subscription.name))
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
                                    navigationManager.path.append(AppNavigation.userDetails(username: subscription.name))
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
                                        navigationManager.path.append(AppNavigation.customFeed(myCustomFeed: customFeed))
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
                                    navigationManager.path.append(AppNavigation.customFeed(myCustomFeed: customFeed))
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

