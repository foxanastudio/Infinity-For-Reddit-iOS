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
                        ForEach(subscriptionListingViewModel.userSubscriptions, id: \.name) { subscription in
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
