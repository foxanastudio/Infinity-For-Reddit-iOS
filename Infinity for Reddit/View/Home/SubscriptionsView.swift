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
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @StateObject var subscriptionListingViewModel: SubscriptionListingViewModel

    @State private var selectedOption = 0
    @State private var navigationBarMenuKey: UUID?
    
    init(subscriptionSelectionMode: SubscriptionSelectionMode = .noSelection) {
        _subscriptionListingViewModel = StateObject(
            wrappedValue: SubscriptionListingViewModel(
                subscriptionSelectionMode: subscriptionSelectionMode,
                subscriptionListingRepository: SubscriptionListingRepository()
            )
        )
    }

    var body: some View {
        RootView {
            VStack(spacing: 0) {
                switch subscriptionListingViewModel.subscriptionSelectionMode {
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
                        switch subscriptionListingViewModel.subscriptionSelectionMode {
                        case .noSelection:
                            SubscribedSubredditListingView(subscriptionListingViewModel: subscriptionListingViewModel)
                                .tag(0)
                            
                            SubscribedUserListingView(subscriptionListingViewModel: subscriptionListingViewModel, onSelectCustomAction: nil)
                                .tag(1)
                            
                            CustomFeedView(subscriptionListingViewModel: subscriptionListingViewModel, customOnTapForSearchInThing: nil)
                                .tag(2)
                        case .searchInThing(let onSelectSearchInThing):
                            SubscribedSubredditListingView(subscriptionListingViewModel: subscriptionListingViewModel) { subscribedSubredditData in
                                onSelectSearchInThing(SearchInThing.subreddit(subscribedSubredditData))
                            }
                            .tag(0)
                            
                            SubscribedUserListingView(subscriptionListingViewModel: subscriptionListingViewModel, onSelectCustomAction: { subscribedUserData in
                                onSelectSearchInThing(SearchInThing.user(subscribedUserData))
                            })
                            .tag(1)
                            
                            CustomFeedView(subscriptionListingViewModel: subscriptionListingViewModel, customOnTapForSearchInThing: onSelectSearchInThing)
                                .tag(2)
                        case .subredditAndUserInCustomFeed:
                            SubscribedSubredditListingMultiSelectionView(subscriptionListingViewModel: subscriptionListingViewModel)
                                .tag(0)
                            
                            SubscribedUserListingMultiSelectionView(subscriptionListingViewModel: subscriptionListingViewModel)
                                .tag(1)
                        }
                    }
                    .toolbar(.hidden, for: .tabBar)
                }
                
                if case .subredditAndUserInCustomFeed(_, let onSelectMultipleSubscriptions) = subscriptionListingViewModel.subscriptionSelectionMode {
                    Button {
                        onSelectMultipleSubscriptions(subscriptionListingViewModel.getSelectedSubredditsAndUsersInCustomFeed())
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
                },
                
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
