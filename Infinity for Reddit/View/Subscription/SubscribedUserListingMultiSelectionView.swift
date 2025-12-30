//
//  SubscribedUserListingMultiSelectionView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import SwiftUI

struct SubscribedUserListingMultiSelectionView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
    
    var body: some View {
        RootView {
            if subscriptionListingViewModel.userSubscriptions.isEmpty {
                ZStack {
                    if subscriptionListingViewModel.isLoadingSubscriptions {
                        ProgressIndicator()
                    } else if let error = subscriptionListingViewModel.error {
                        Text("Unable to load subscribed users. Tap to retry. Error: \(error.localizedDescription)")
                            .primaryText()
                            .padding(16)
                            .onTapGesture {
                                subscriptionListingViewModel.refreshSubscriptions()
                            }
                    } else {
                        Text("No subscribed users")
                            .primaryText()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    if !subscriptionListingViewModel.favoriteUserSubscriptions.isEmpty {
                        CustomListSection("Favorite") {
                            ForEach(subscriptionListingViewModel.favoriteUserSubscriptions, id: \.name) { subscription in
                                SubscriptionItemMultiSelectionView(
                                    text: subscription.name,
                                    iconUrl: subscription.iconUrl,
                                    isSelected: isUserSelected(subscription)
                                ) {
                                    toggleSelection(subscription)
                                }
                                .listPlainItemNoInsets()
                            }
                        }
                    }
                    
                    CustomListSection("All") {
                        ForEach(subscriptionListingViewModel.userSubscriptions, id: \.name) { subscription in
                            SubscriptionItemMultiSelectionView(
                                text: subscription.name,
                                iconUrl: subscription.iconUrl,
                                isSelected: isUserSelected(subscription)
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
    
    func isUserSelected(_ subscription: SubscribedUserData) -> Bool {
        return subscriptionListingViewModel.selectedSubscribedUsers.index(id: subscription.id) != nil
        || subscriptionListingViewModel.selectedUsers.index(id: subscription.id) != nil
        || subscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: "u_\(subscription.name)") != nil
    }
    
    func toggleSelection(_ subscription: SubscribedUserData) {
        if subscriptionListingViewModel.selectedSubscribedUsers.index(id: subscription.id) != nil {
            subscriptionListingViewModel.selectedSubscribedUsers.remove(id: subscription.id)
        } else if subscriptionListingViewModel.selectedUsers.index(id: subscription.id) != nil {
            subscriptionListingViewModel.selectedUsers.remove(id: subscription.id)
        } else if subscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: "u_\(subscription.name)") != nil {
            subscriptionListingViewModel.selectedSubredditsInCustomFeed.remove(id: "u_\(subscription.name)")
        } else {
            subscriptionListingViewModel.selectedSubscribedUsers.append(subscription)
        }
    }
}
