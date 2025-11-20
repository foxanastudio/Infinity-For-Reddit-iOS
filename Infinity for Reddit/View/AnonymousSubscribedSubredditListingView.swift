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
        Group {
            if anonymousSubscriptionListingViewModel.subredditSubscriptions.isEmpty {
                Text("No subscribed subreddits")
                    .primaryText()
            } else {
                List {
                    if !anonymousSubscriptionListingViewModel.favoriteSubredditSubscriptions.isEmpty {
                        CustomListSection("Favorite") {
                            ForEach(anonymousSubscriptionListingViewModel.favoriteSubredditSubscriptions, id: \.identityInView) { subscription in
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
                            }
                        }
                    }
                    
                    CustomListSection("All") {
                        ForEach(anonymousSubscriptionListingViewModel.subredditSubscriptions, id: \.identityInView) { subscription in
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
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .themedList()
            }
        }
    }
}
