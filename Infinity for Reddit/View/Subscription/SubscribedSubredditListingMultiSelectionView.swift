//
//  SubscribedSubredditListingMultiSelectionView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import SwiftUI

struct SubscribedSubredditListingMultiSelectionView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel

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
                        CustomListSection("Favorite") {
                            ForEach(subscriptionListingViewModel.favoriteSubredditSubscriptions, id: \.identityInView) { subscription in
                                SubscriptionItemMultiSelectionView(
                                    text: subscription.name,
                                    iconUrl: subscription.iconUrl,
                                    isSelected: isSubredditSelected(subscription)
                                ) {
                                    if subscriptionListingViewModel.selectedSubscribedSubreddits.index(id: subscription.id) != nil {
                                        subscriptionListingViewModel.selectedSubscribedSubreddits.remove(subscription)
                                    } else if subscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: subscription.name) != nil {
                                        subscriptionListingViewModel.selectedSubredditsInCustomFeed.remove(id: subscription.name)
                                    } else {
                                        subscriptionListingViewModel.selectedSubscribedSubreddits.append(subscription)
                                    }
                                }
                                .listPlainItemNoInsets()
                            }
                        }
                    }
                    
                    CustomListSection("All") {
                        ForEach(subscriptionListingViewModel.subredditSubscriptions, id: \.identityInView) { subscription in
                            SubscriptionItemMultiSelectionView(
                                text: subscription.name,
                                iconUrl: subscription.iconUrl,
                                isSelected: isSubredditSelected(subscription)
                            ) {
                                if subscriptionListingViewModel.selectedSubscribedSubreddits.index(id: subscription.id) != nil {
                                    subscriptionListingViewModel.selectedSubscribedSubreddits.remove(subscription)
                                } else if subscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: subscription.name) != nil {
                                    subscriptionListingViewModel.selectedSubredditsInCustomFeed.remove(id: subscription.name)
                                } else {
                                    subscriptionListingViewModel.selectedSubscribedSubreddits.append(subscription)
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
        return subscriptionListingViewModel.selectedSubscribedSubreddits.index(id: subscribedSubreddit.id) != nil
        || subscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: subscribedSubreddit.name) != nil
    }
}
