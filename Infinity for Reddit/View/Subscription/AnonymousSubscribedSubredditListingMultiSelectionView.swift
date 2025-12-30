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
                            ForEach(anonymousSubscriptionListingViewModel.favoriteSubredditSubscriptions, id: \.fullName) { subscription in
                                SubscriptionItemMultiSelectionView(
                                    text: subscription.name,
                                    iconUrl: subscription.iconUrl,
                                    isSelected: isSubredditSelected(subscription)
                                ) {
                                    toggleSelection(subscription)
                                }
                                .listPlainItemNoInsets()
                            }
                        }
                    }
                    
                    CustomListSection("All") {
                        ForEach(anonymousSubscriptionListingViewModel.subredditSubscriptions, id: \.fullName) { subscription in
                            SubscriptionItemMultiSelectionView(
                                text: subscription.name,
                                iconUrl: subscription.iconUrl,
                                isSelected: isSubredditSelected(subscription)
                            ) {
                                toggleSelection(subscription)
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
    
    func isSubredditSelected(_ subscription: SubscribedSubredditData) -> Bool {
        return anonymousSubscriptionListingViewModel.selectedSubscribedSubreddits.index(id: subscription.id) != nil
        || anonymousSubscriptionListingViewModel.selectedSubreddits.index(id: subscription.id) != nil
        || anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: subscription.name) != nil
    }
    
    func toggleSelection(_ subscription: SubscribedSubredditData) {
        if anonymousSubscriptionListingViewModel.selectedSubscribedSubreddits.index(id: subscription.id) != nil {
            anonymousSubscriptionListingViewModel.selectedSubscribedSubreddits.remove(subscription)
        } else if anonymousSubscriptionListingViewModel.selectedSubreddits.index(id: subscription.id) != nil {
            anonymousSubscriptionListingViewModel.selectedSubreddits.remove(id: subscription.id)
        } else if anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: subscription.name) != nil {
            anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.remove(id: subscription.name)
        } else {
            anonymousSubscriptionListingViewModel.selectedSubscribedSubreddits.append(subscription)
        }
    }
}
