//
//  SubscribedSubredditListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-17.
//

import SwiftUI

struct SubscribedSubredditListingView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
    
    let showCurrentAccountSubreddit: Bool
    let onSelectCustomAction: ((SubscribedSubredditData) -> Void)?
    
    init(
        showCurrentAccountSubreddit: Bool = false,
        subscriptionListingViewModel: SubscriptionListingViewModel,
        onSelectCustomAction: ((SubscribedSubredditData) -> Void)? = nil
    ) {
        self.showCurrentAccountSubreddit = showCurrentAccountSubreddit
        self.subscriptionListingViewModel = subscriptionListingViewModel
        self.onSelectCustomAction = onSelectCustomAction
    }
    
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
                    if showCurrentAccountSubreddit && !accountViewModel.account.isAnonymous() {
                        let account = accountViewModel.account
                        SubscriptionItemView(text: account.username, iconUrl: account.profileImageUrl, action: {
                            // This view will only appear when selecting a subreddit for post submission so we only care about onSelectCustomAction
                            if let onSelectCustomAction = onSelectCustomAction {
                                // We only care about the icon url subreddit name and username
                                onSelectCustomAction(SubscribedSubredditData(name: "u_\(account.username)", iconUrl: account.profileImageUrl, username: account.username))
                            }
                        })
                        .listPlainItemNoInsets()
                    }
                    
                    if !subscriptionListingViewModel.favoriteSubredditSubscriptions.isEmpty {
                        CustomListSection("Favorite") {
                            ForEach(subscriptionListingViewModel.favoriteSubredditSubscriptions, id: \.fullName) { subscription in
                                SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                    if let onSelectCustomAction {
                                        onSelectCustomAction(subscription)
                                    } else {
                                        navigationManager.append(AppNavigation.subredditDetails(subredditName: subscription.name))
                                    }
                                }) {
                                    subscription.isFavorite.toggle()
                                    Task {
                                        await subscriptionListingViewModel.toggleFavoriteSubreddit(subscription)
                                    }
                                }
                                .listPlainItemNoInsets()
                                .applyIf(onSelectCustomAction == nil) {
                                    $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            Task {
                                                await subscriptionListingViewModel.unsubscribeFromSubreddit(subscription)
                                            }
                                        } label: {
                                            Text("Unsubscribe")
                                                .foregroundStyle(.white)
                                        }
                                        .tint(.red)
                                    }
                                }
                            }
                        }
                    }
                    
                    CustomListSection("All") {
                        ForEach(subscriptionListingViewModel.subredditSubscriptions, id: \.fullName) { subscription in
                            SubscriptionItemView(text: subscription.name, iconUrl: subscription.iconUrl, isFavorite: subscription.isFavorite, action: {
                                if let onSelectCustomAction {
                                    onSelectCustomAction(subscription)
                                } else {
                                    navigationManager.append(AppNavigation.subredditDetails(subredditName: subscription.name))
                                }
                            }) {
                                subscription.isFavorite.toggle()
                                Task {
                                    await subscriptionListingViewModel.toggleFavoriteSubreddit(subscription)
                                }
                            }
                            .listPlainItemNoInsets()
                            .applyIf(onSelectCustomAction == nil) {
                                $0.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            await subscriptionListingViewModel.unsubscribeFromSubreddit(subscription)
                                        }
                                    } label: {
                                        Text("Unsubscribe")
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
