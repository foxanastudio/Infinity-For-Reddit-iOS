//
//  AnonymousSubscribedUserListingMultiSelectionView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-20.
//

import SwiftUI

struct AnonymousSubscribedUserListingMultiSelectionView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @ObservedObject var anonymousSubscriptionListingViewModel: AnonymousSubscriptionListingViewModel
    
    var body: some View {
        Group {
            if anonymousSubscriptionListingViewModel.userSubscriptions.isEmpty {
                Text("No subscribed users")
                    .primaryText()
            } else {
                List {
                    if !anonymousSubscriptionListingViewModel.favoriteUserSubscriptions.isEmpty {
                        CustomListSection("Favorite") {
                            ForEach(anonymousSubscriptionListingViewModel.favoriteUserSubscriptions, id: \.identityInView) { subscription in
                                SubscriptionItemMultiSelectionView(
                                    text: subscription.name,
                                    iconUrl: subscription.iconUrl,
                                    isSelected: anonymousSubscriptionListingViewModel.selectedSubscribedUsers.index(id: subscription.id) != nil
                                ) {
                                    if anonymousSubscriptionListingViewModel.selectedSubscribedUsers.index(id: subscription.id) != nil {
                                        anonymousSubscriptionListingViewModel.selectedSubscribedUsers.remove(subscription)
                                    } else if anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: "u_\(subscription.name)") != nil {
                                        anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.remove(id: "u_\(subscription.name)")
                                    } else {
                                        anonymousSubscriptionListingViewModel.selectedSubscribedUsers.append(subscription)
                                    }
                                }
                                .listPlainItemNoInsets()
                            }
                        }
                    }
                    
                    CustomListSection("All") {
                        ForEach(anonymousSubscriptionListingViewModel.userSubscriptions, id: \.identityInView) { subscription in
                            SubscriptionItemMultiSelectionView(
                                text: subscription.name,
                                iconUrl: subscription.iconUrl,
                                isSelected: isUserSelected(subscription)
                            ) {
                                if anonymousSubscriptionListingViewModel.selectedSubscribedUsers.index(id: subscription.id) != nil {
                                    anonymousSubscriptionListingViewModel.selectedSubscribedUsers.remove(subscription)
                                } else if anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: "u_\(subscription.name)") != nil {
                                    anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.remove(id: "u_\(subscription.name)")
                                } else {
                                    anonymousSubscriptionListingViewModel.selectedSubscribedUsers.append(subscription)
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
    
    func isUserSelected(_ subscribedUser: SubscribedUserData) -> Bool {
        return anonymousSubscriptionListingViewModel.selectedSubscribedUsers.index(id: subscribedUser.id) != nil
        || anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: "u_\(subscribedUser.name)") != nil
    }
}
