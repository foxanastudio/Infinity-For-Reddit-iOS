//
//  SubscribedUserListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import SwiftUI

struct SubscribedUserListingView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
    
    let onSelectCustomAction: ((SubscribedUserData) -> Void)?
    
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
                                SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                    if let onSelectCustomAction = onSelectCustomAction {
                                        onSelectCustomAction(subscription)
                                    } else {
                                        navigationManager.append(AppNavigation.userDetails(username: subscription.name))
                                    }
                                }) {
                                    subscription.isFavorite.toggle()
                                    Task {
                                        await subscriptionListingViewModel.toggleFavoriteUser(subscription)
                                    }
                                }
                                .listPlainItemNoInsets()
                                .applyIf(onSelectCustomAction == nil) {
                                    $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            Task {
                                                await subscriptionListingViewModel.unfollowUser(subscription)
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
                        ForEach(subscriptionListingViewModel.userSubscriptions, id: \.identityInView) { subscription in
                            SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                if let onSelectCustomAction = onSelectCustomAction {
                                    onSelectCustomAction(subscription)
                                } else {
                                    navigationManager.append(AppNavigation.userDetails(username: subscription.name))
                                }
                            }) {
                                subscription.isFavorite.toggle()
                                Task {
                                    await subscriptionListingViewModel.toggleFavoriteUser(subscription)
                                }
                            }
                            .listPlainItemNoInsets()
                            .applyIf(onSelectCustomAction == nil) {
                                $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            await subscriptionListingViewModel.unfollowUser(subscription)
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
