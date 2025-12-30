//
//  AnonymousSubscribedSubredditListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-20.
//

import SwiftUI

struct AnonymousSubscribedSubredditListingView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var anonymousSubscriptionListingViewModel: AnonymousSubscriptionListingViewModel
    
    let onSelectCustomAction: ((SubscribedSubredditData) -> Void)?
    
    init(
        anonymousSubscriptionListingViewModel: AnonymousSubscriptionListingViewModel,
        onSelectCustomAction: ((SubscribedSubredditData) -> Void)? = nil
    ) {
        self.anonymousSubscriptionListingViewModel = anonymousSubscriptionListingViewModel
        self.onSelectCustomAction = onSelectCustomAction
    }
    
    var body: some View {
        RootView {
            if anonymousSubscriptionListingViewModel.subredditSubscriptions.isEmpty {
                ZStack {
                    Text("No subscribed subreddits")
                        .primaryText()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    if !anonymousSubscriptionListingViewModel.favoriteSubredditSubscriptions.isEmpty {
                        CustomListSection("Favorite") {
                            ForEach(anonymousSubscriptionListingViewModel.favoriteSubredditSubscriptions, id: \.fullName) { subscription in
                                SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                    if let onSelectCustomAction {
                                        onSelectCustomAction(subscription)
                                    } else {
                                        navigationManager.append(AppNavigation.subredditDetails(subredditName: subscription.name))
                                    }
                                }) {
                                    subscription.isFavorite.toggle()
                                    anonymousSubscriptionListingViewModel.toggleFavoriteSubreddit(subscription)
                                }
                                .listPlainItemNoInsets()
                                .applyIf(onSelectCustomAction == nil) {
                                    $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            Task {
                                                await anonymousSubscriptionListingViewModel.unsubscribeFromSubreddit(subscription)
                                            }
                                        } label: {
                                            Text("Unsubscribe")
                                                .foregroundStyle(.white)
                                        }
                                        .tint(.red)
                                    }
                                }
                            }
                        }
                    }
                    
                    CustomListSection("All") {
                        ForEach(anonymousSubscriptionListingViewModel.subredditSubscriptions, id: \.fullName) { subscription in
                            SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                if let onSelectCustomAction {
                                    onSelectCustomAction(subscription)
                                } else {
                                    navigationManager.append(AppNavigation.subredditDetails(subredditName: subscription.name))
                                }
                            }) {
                                subscription.isFavorite.toggle()
                                anonymousSubscriptionListingViewModel.toggleFavoriteSubreddit(subscription)
                            }
                            .listPlainItemNoInsets()
                            .applyIf(onSelectCustomAction == nil) {
                                $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            await anonymousSubscriptionListingViewModel.unsubscribeFromSubreddit(subscription)
                                        }
                                    } label: {
                                        Text("Unsubscribe")
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
