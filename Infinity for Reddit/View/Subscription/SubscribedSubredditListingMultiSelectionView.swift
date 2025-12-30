//
//  SubscribedSubredditListingMultiSelectionView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import SwiftUI

struct SubscribedSubredditListingMultiSelectionView: View {
    @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel

    var body: some View {
        RootView {
            if subscriptionListingViewModel.subredditSubscriptions.isEmpty {
                ZStack {
                    if subscriptionListingViewModel.isLoadingSubscriptions {
                        ProgressIndicator()
                    } else if let error = subscriptionListingViewModel.error {
                        Text("Unable to load subscribed subreddits. Tap to retry. Error: \(error.localizedDescription)")
                            .primaryText()
                            .padding(16)
                            .onTapGesture {
                                subscriptionListingViewModel.refreshSubscriptions()
                            }
                    } else {
                        Text("No subscribed subreddits")
                            .primaryText()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    if !subscriptionListingViewModel.favoriteSubredditSubscriptions.isEmpty {
                        CustomListSection("Favorite") {
                            ForEach(subscriptionListingViewModel.favoriteSubredditSubscriptions, id: \.fullName) { subscription in
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
                        ForEach(subscriptionListingViewModel.subredditSubscriptions, id: \.fullName) { subscription in
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
        return subscriptionListingViewModel.selectedSubscribedSubreddits.index(id: subscription.id) != nil
        || subscriptionListingViewModel.selectedSubreddits.index(id: subscription.id) != nil
        || subscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: subscription.name) != nil
    }
    
    func toggleSelection(_ subscription: SubscribedSubredditData) {
        if subscriptionListingViewModel.selectedSubscribedSubreddits.index(id: subscription.id) != nil {
            subscriptionListingViewModel.selectedSubscribedSubreddits.remove(subscription)
        } else if subscriptionListingViewModel.selectedSubreddits.index(id: subscription.id) != nil {
            subscriptionListingViewModel.selectedSubreddits.remove(id: subscription.id)
        } else if subscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: subscription.name) != nil {
            subscriptionListingViewModel.selectedSubredditsInCustomFeed.remove(id: subscription.name)
        } else {
            subscriptionListingViewModel.selectedSubscribedSubreddits.append(subscription)
        }
    }
}
