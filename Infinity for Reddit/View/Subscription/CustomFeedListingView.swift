//
//  CustomFeedListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-14.
//

import SwiftUI

struct CustomFeedListingView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
    
    let onSelectCustomAction: ((Thing) -> Void)?
    
    var body: some View {
        RootView {
            if subscriptionListingViewModel.myCustomFeeds.isEmpty {
                ZStack {
                    if subscriptionListingViewModel.isLoadingMyCustomFeeds {
                        ProgressIndicator()
                    } else if let error = subscriptionListingViewModel.error {
                        Text("Unable to load custom feeds. Tap to retry. Error: \(error.localizedDescription)")
                            .primaryText()
                            .padding(16)
                            .onTapGesture {
                                subscriptionListingViewModel.refreshSubscriptions()
                            }
                    } else {
                        Text("No custom feeds")
                            .primaryText()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    if !subscriptionListingViewModel.favoriteMyCustomFeeds.isEmpty {
                        CustomListSection("Favorite") {
                            ForEach(subscriptionListingViewModel.favoriteMyCustomFeeds, id: \.path) { customFeed in
                                SubscriptionItemView(text: customFeed.displayName, iconUrl: customFeed.iconUrl, isFavorite: customFeed.isFavorite, action: {
                                    if let onSelectCustomAction {
                                        onSelectCustomAction(Thing.myCustomFeed(customFeed))
                                    } else {
                                        navigationManager.append(AppNavigation.customFeed(customFeed: .myCustomFeed(customFeed)))
                                    }
                                }) {
                                    customFeed.isFavorite.toggle()
                                    Task {
                                        await subscriptionListingViewModel.toggleFavoriteCustomFeed(customFeed)
                                    }
                                }
                                .listPlainItemNoInsets()
                                .applyIf(onSelectCustomAction == nil) {
                                    $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            Task {
                                                await subscriptionListingViewModel.deleteCustomFeed(customFeed)
                                            }
                                        } label: {
                                            Text("Delete")
                                                .foregroundStyle(.white)
                                        }
                                        .tint(.red)
                                    }
                                }
                            }
                        }
                    }
                    
                    CustomListSection("All") {
                        ForEach(subscriptionListingViewModel.myCustomFeeds, id: \.path) { customFeed in
                            SubscriptionItemView(text: customFeed.displayName, iconUrl: customFeed.iconUrl, isFavorite: customFeed.isFavorite, action: {
                                if let onSelectCustomAction {
                                    onSelectCustomAction(Thing.myCustomFeed(customFeed))
                                } else {
                                    navigationManager.append(AppNavigation.customFeed(customFeed: .myCustomFeed(customFeed)))
                                }
                            }) {
                                customFeed.isFavorite.toggle()
                                Task {
                                    await subscriptionListingViewModel.toggleFavoriteCustomFeed(customFeed)
                                }
                            }
                            .listPlainItemNoInsets()
                            .applyIf(onSelectCustomAction == nil) {
                                $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            await subscriptionListingViewModel.deleteCustomFeed(customFeed)
                                        }
                                    } label: {
                                        Text("Delete")
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
