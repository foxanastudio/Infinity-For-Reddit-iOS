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
                        CustomListSection("Favorite") {
                            ForEach(subscriptionListingViewModel.favoriteUserSubscriptions, id: \.identityInView) { subscription in
                                SubscriptionItemMultiSelectionView(
                                    text: subscription.name,
                                    iconUrl: subscription.iconUrl,
                                    isSelected: subscriptionListingViewModel.selectedSubscribedUsers.index(id: subscription.id) != nil
                                ) {
                                    if subscriptionListingViewModel.selectedSubscribedUsers.index(id: subscription.id) != nil {
                                        subscriptionListingViewModel.selectedSubscribedUsers.remove(subscription)
                                    } else {
                                        subscriptionListingViewModel.selectedSubscribedUsers.append(subscription)
                                    }
                                }
                                .listPlainItemNoInsets()
                            }
                        }
                    }
                    
                    CustomListSection("All") {
                        ForEach(subscriptionListingViewModel.userSubscriptions, id: \.identityInView) { subscription in
                            SubscriptionItemMultiSelectionView(
                                text: subscription.name,
                                iconUrl: subscription.iconUrl,
                                isSelected: subscriptionListingViewModel.selectedSubscribedUsers.index(id: subscription.id) != nil
                            ) {
                                if subscriptionListingViewModel.selectedSubscribedUsers.index(id: subscription.id) != nil {
                                    subscriptionListingViewModel.selectedSubscribedUsers.remove(subscription)
                                } else {
                                    subscriptionListingViewModel.selectedSubscribedUsers.append(subscription)
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
}
