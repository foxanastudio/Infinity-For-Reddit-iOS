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
        Group {
            if anonymousSubscriptionListingViewModel.userSubscriptions.isEmpty {
                Text("No subscribed users")
                    .primaryText()
            } else {
                List {
                    if !anonymousSubscriptionListingViewModel.favoriteUserSubscriptions.isEmpty {
                        CustomListSection("Favorite") {
                            ForEach(anonymousSubscriptionListingViewModel.favoriteUserSubscriptions, id: \.identityInView) { subscription in
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
                    }
                    
                    CustomListSection("All") {
                        ForEach(anonymousSubscriptionListingViewModel.userSubscriptions, id: \.identityInView) { subscription in
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
                }
                .scrollBounceBehavior(.basedOnSize)
                .themedList()
            }
        }
    }
}
