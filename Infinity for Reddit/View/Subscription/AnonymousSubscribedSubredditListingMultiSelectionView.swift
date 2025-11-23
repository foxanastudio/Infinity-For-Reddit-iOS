//
//  AnonymousSubscribedSubredditListingMultiSelectionView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-20.
//

import SwiftUI

struct AnonymousSubscribedSubredditListingMultiSelectionView: View {
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
                        CustomListSection("Favorite") {
                            ForEach(anonymousSubscriptionListingViewModel.favoriteSubredditSubscriptions, id: \.identityInView) { subscription in
                                SubscriptionItemMultiSelectionView(
                                    text: subscription.name,
                                    iconUrl: subscription.iconUrl,
                                    isSelected: isSubredditSelected(subscription)
                                ) {
                                    if anonymousSubscriptionListingViewModel.selectedSubscribedSubreddits.index(id: subscription.id) != nil {
                                        anonymousSubscriptionListingViewModel.selectedSubscribedSubreddits.remove(subscription)
                                    } else if anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: subscription.name) != nil {
                                        anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.remove(id: subscription.name)
                                    } else {
                                        anonymousSubscriptionListingViewModel.selectedSubscribedSubreddits.append(subscription)
                                    }
                                }
                                .listPlainItemNoInsets()
                            }
                        }
                    }
                    
                    CustomListSection("All") {
                        ForEach(anonymousSubscriptionListingViewModel.subredditSubscriptions, id: \.identityInView) { subscription in
                            SubscriptionItemMultiSelectionView(
                                text: subscription.name,
                                iconUrl: subscription.iconUrl,
                                isSelected: isSubredditSelected(subscription)
                            ) {
                                if anonymousSubscriptionListingViewModel.selectedSubscribedSubreddits.index(id: subscription.id) != nil {
                                    anonymousSubscriptionListingViewModel.selectedSubscribedSubreddits.remove(subscription)
                                } else if anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: subscription.name) != nil {
                                    anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.remove(id: subscription.name)
                                } else {
                                    anonymousSubscriptionListingViewModel.selectedSubscribedSubreddits.append(subscription)
                                }
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
    
    func isSubredditSelected(_ subscribedSubreddit: SubscribedSubredditData) -> Bool {
        return anonymousSubscriptionListingViewModel.selectedSubscribedSubreddits.index(id: subscribedSubreddit.id) != nil
        || anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: subscribedSubreddit.name) != nil
    }
}
