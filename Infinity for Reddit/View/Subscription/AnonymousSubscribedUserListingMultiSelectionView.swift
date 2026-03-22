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
        if anonymousSubscriptionListingViewModel.userSubscriptions.isEmpty {
            ZStack {
                Text("No subscribed users")
                    .primaryText()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                if !anonymousSubscriptionListingViewModel.favoriteUserSubscriptions.isEmpty {
                    StaticListSection("Favorite")
                    
                    ForEach(anonymousSubscriptionListingViewModel.favoriteUserSubscriptions, id: \.name) { subscription in
                        SubscriptionItemMultiSelectionView(
                            text: subscription.name,
                            iconUrl: subscription.iconUrl,
                            isSelected: anonymousSubscriptionListingViewModel.selectedSubscribedUsers.index(id: subscription.id) != nil
                        ) {
                            toggleSelection(subscription)
                        }
                        .limitedWidth()
                        .listPlainItemNoInsets()
                    }
                }
                
                if !anonymousSubscriptionListingViewModel.favoriteUserSubscriptions.isEmpty {
                    StaticListSection("All")
                }
                
                ForEach(anonymousSubscriptionListingViewModel.userSubscriptions, id: \.name) { subscription in
                    SubscriptionItemMultiSelectionView(
                        text: subscription.name,
                        iconUrl: subscription.iconUrl,
                        isSelected: isUserSelected(subscription)
                    ) {
                        toggleSelection(subscription)
                    }
                    .limitedWidth()
                    .listPlainItemNoInsets()
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .themedList()
        }
    }
    
    func isUserSelected(_ subscription: SubscribedUserData) -> Bool {
        return anonymousSubscriptionListingViewModel.selectedSubscribedUsers.index(id: subscription.id) != nil
        || anonymousSubscriptionListingViewModel.selectedUsers.index(id: subscription.name) != nil
        || anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: "u_\(subscription.name)") != nil
    }
    
    func toggleSelection(_ subscription: SubscribedUserData) {
        if anonymousSubscriptionListingViewModel.selectedSubscribedUsers.index(id: subscription.id) != nil {
            anonymousSubscriptionListingViewModel.selectedSubscribedUsers.remove(subscription)
        } else if anonymousSubscriptionListingViewModel.selectedUsers.index(id: subscription.name) != nil {
            anonymousSubscriptionListingViewModel.selectedUsers.remove(id: subscription.name)
        } else if anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.index(id: "u_\(subscription.name)") != nil {
            anonymousSubscriptionListingViewModel.selectedSubredditsInCustomFeed.remove(id: "u_\(subscription.name)")
        } else {
            anonymousSubscriptionListingViewModel.selectedSubscribedUsers.append(subscription)
        }
    }
}
