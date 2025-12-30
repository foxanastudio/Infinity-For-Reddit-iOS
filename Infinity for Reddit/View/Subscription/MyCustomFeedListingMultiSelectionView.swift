//
//  MyCustomFeedListingMultiSelectionView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-14.
//

import SwiftUI

struct MyCustomFeedListingMultiSelectionView: View {
    @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
    
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
                                SubscriptionItemMultiSelectionView(
                                    text: customFeed.displayName,
                                    iconUrl: customFeed.iconUrl,
                                    isSelected: subscriptionListingViewModel.selectedMyCustomFeeds.index(id: customFeed.id) != nil
                                ) {
                                    toggleSelection(customFeed)
                                }
                                .listPlainItemNoInsets()
                            }
                        }
                    }
                    
                    CustomListSection("All") {
                        ForEach(subscriptionListingViewModel.myCustomFeeds, id: \.path) { customFeed in
                            SubscriptionItemMultiSelectionView(
                                text: customFeed.displayName,
                                iconUrl: customFeed.iconUrl,
                                isSelected: subscriptionListingViewModel.selectedMyCustomFeeds.index(id: customFeed.id) != nil
                            ) {
                                toggleSelection(customFeed)
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
    
    func toggleSelection(_ myCustomFeed: MyCustomFeed) {
        if subscriptionListingViewModel.selectedMyCustomFeeds.index(id: myCustomFeed.id) != nil {
            subscriptionListingViewModel.selectedMyCustomFeeds.remove(id: myCustomFeed.id)
        } else {
            subscriptionListingViewModel.selectedMyCustomFeeds.append(myCustomFeed)
        }
    }
}
