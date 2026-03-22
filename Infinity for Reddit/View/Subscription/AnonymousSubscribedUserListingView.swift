//
//  AnonymousSubscribedUserListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-20.
//

import SwiftUI

struct AnonymousSubscribedUserListingView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var anonymousSubscriptionListingViewModel: AnonymousSubscriptionListingViewModel
    
    let onSelectCustomAction: ((SubscribedUserData) -> Void)?
    
    init(
        anonymousSubscriptionListingViewModel: AnonymousSubscriptionListingViewModel,
        onSelectCustomAction: ((SubscribedUserData) -> Void)? = nil
    ) {
        self.anonymousSubscriptionListingViewModel = anonymousSubscriptionListingViewModel
        self.onSelectCustomAction = onSelectCustomAction
    }
    
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
                        SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                            if let onSelectCustomAction {
                                onSelectCustomAction(subscription)
                            } else {
                                navigationManager.append(AppNavigation.userDetails(username: subscription.name))
                            }
                        }) {
                            subscription.isFavorite.toggle()
                            anonymousSubscriptionListingViewModel.toggleFavoriteUser(subscription)
                        }
                        .limitedWidth()
                        .id(ObjectIdentifier(subscription))
                        .listPlainItemNoInsets()
                        .applyIf(onSelectCustomAction == nil) {
                            $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task {
                                        await anonymousSubscriptionListingViewModel.unfollowUser(subscription)
                                    }
                                } label: {
                                    Text("Unfollow")
                                        .foregroundStyle(.white)
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
                
                if !anonymousSubscriptionListingViewModel.favoriteUserSubscriptions.isEmpty {
                    StaticListSection("All")
                }
                
                ForEach(anonymousSubscriptionListingViewModel.userSubscriptions, id: \.name) { subscription in
                    SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                        if let onSelectCustomAction {
                            onSelectCustomAction(subscription)
                        } else {
                            navigationManager.append(AppNavigation.userDetails(username: subscription.name))
                        }
                    }) {
                        subscription.isFavorite.toggle()
                        anonymousSubscriptionListingViewModel.toggleFavoriteUser(subscription)
                    }
                    .limitedWidth()
                    .id(ObjectIdentifier(subscription))
                    .listPlainItemNoInsets()
                    .applyIf(onSelectCustomAction == nil) {
                        $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                Task {
                                    await anonymousSubscriptionListingViewModel.unfollowUser(subscription)
                                }
                            } label: {
                                Text("Unfollow")
                                    .foregroundStyle(.white)
                            }
                            .tint(.red)
                        }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .themedList()
        }
    }
}
