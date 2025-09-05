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
    
    init() {
        _anonymousSubscriptionListingViewModel = StateObject(
            wrappedValue: AnonymousSubscriptionListingViewModel(anonymousSubscriptionListingRepository: AnonymousSubscriptionListingRepository())
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            SegmentedPicker(selectedValue: $selectedOption, values: ["Subreddits", "Users", "Custom Feed"])
                .padding(4)
            
            TabView(selection: $selectedOption) {
                AnonymousSubredditsView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                    .tag(0)
                
                AnonymousUsersView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                    .tag(1)
                
                AnonymousCustomFeedView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .rootViewBackground()
        .navigationTitle("Subscriptions")
    }
    
    struct AnonymousSubredditsView: View {
        @EnvironmentObject var navigationManager: NavigationManager
        @ObservedObject var anonymousSubscriptionListingViewModel: AnonymousSubscriptionListingViewModel
        
        var body: some View {
            Group {
                if anonymousSubscriptionListingViewModel.subredditSubscriptions.isEmpty {
                    Text("No subscribed subreddits")
                        .primaryText()
                } else {
                    List {
                        if !anonymousSubscriptionListingViewModel.favoriteSubredditSubscriptions.isEmpty {
                            Section(header: Text("Favorite").listSectionHeader()) {
                                ForEach(anonymousSubscriptionListingViewModel.favoriteSubredditSubscriptions, id: \.identityInView) { subscription in
                                    SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                        navigationManager.path.append(AppNavigation.subredditDetails(subredditName: subscription.name))
                                    }) {
                                        subscription.isFavorite.toggle()
                                        anonymousSubscriptionListingViewModel.toggleFavoriteSubreddit(subscription)
                                    }
                                    .listPlainItemNoInsets()
                                }
                            }
                            .listPlainItem()
                        }
                        
                        Section(header: Text("All").listSectionHeader()) {
                            ForEach(anonymousSubscriptionListingViewModel.subredditSubscriptions, id: \.identityInView) { subscription in
                                SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                    navigationManager.path.append(AppNavigation.subredditDetails(subredditName: subscription.name))
                                }) {
                                    subscription.isFavorite.toggle()
                                    anonymousSubscriptionListingViewModel.toggleFavoriteSubreddit(subscription)
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

    struct AnonymousUsersView: View {
        @EnvironmentObject var navigationManager: NavigationManager
        @ObservedObject var anonymousSubscriptionListingViewModel: AnonymousSubscriptionListingViewModel
        
        var body: some View {
            Group {
                if anonymousSubscriptionListingViewModel.userSubscriptions.isEmpty {
                    Text("No subscribed users")
                        .primaryText()
                } else {
                    List {
                        if !anonymousSubscriptionListingViewModel.favoriteUserSubscriptions.isEmpty {
                            Section(header: Text("Favorite").listSectionHeader()) {
                                ForEach(anonymousSubscriptionListingViewModel.favoriteUserSubscriptions, id: \.identityInView) { subscription in
                                    SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                        navigationManager.path.append(AppNavigation.userDetails(username: subscription.name))
                                    }) {
                                        subscription.isFavorite.toggle()
                                        anonymousSubscriptionListingViewModel.toggleFavoriteUser(subscription)
                                    }
                                    .listPlainItemNoInsets()
                                }
                            }
                            .listPlainItem()
                        }
                        
                        Section(header: Text("All").listSectionHeader()) {
                            ForEach(anonymousSubscriptionListingViewModel.userSubscriptions, id: \.identityInView) { subscription in
                                SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                    navigationManager.path.append(AppNavigation.userDetails(username: subscription.name))
                                }) {
                                    subscription.isFavorite.toggle()
                                    anonymousSubscriptionListingViewModel.toggleFavoriteUser(subscription)
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
                            Section(header: Text("Favorite").listSectionHeader()) {
                                ForEach(anonymousSubscriptionListingViewModel.favoriteMyCustomFeeds, id: \.identityInView) { customFeed in
                                    SubscriptionItemView(text: customFeed.displayName, iconUrl: customFeed.iconUrl, isFavorite: customFeed.isFavorite, action: {
                                        navigationManager.path.append(AppNavigation.customFeed(myCustomFeed: customFeed))
                                    }) {
                                        customFeed.isFavorite.toggle()
                                        anonymousSubscriptionListingViewModel.toggleFavoriteCustomFeed(customFeed)
                                    }
                                    .listPlainItemNoInsets()
                                }
                            }
                            .listPlainItem()
                        }
                        
                        Section(header: Text("All").listSectionHeader()) {
                            ForEach(anonymousSubscriptionListingViewModel.myCustomFeeds, id: \.identityInView) { customFeed in
                                SubscriptionItemView(text: customFeed.displayName, iconUrl: customFeed.iconUrl, isFavorite: customFeed.isFavorite, action: {
                                    navigationManager.path.append(AppNavigation.customFeed(myCustomFeed: customFeed))
                                }) {
                                    customFeed.isFavorite.toggle()
                                    anonymousSubscriptionListingViewModel.toggleFavoriteCustomFeed(customFeed)
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
