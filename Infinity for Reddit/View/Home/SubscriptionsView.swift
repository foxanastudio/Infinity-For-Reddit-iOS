//
//  SubscriptionsView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-03.
//

import SwiftUI
import Swinject
import GRDB
import Alamofire
import SDWebImageSwiftUI

struct SubscriptionsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @StateObject var subscriptionListingViewModel: SubscriptionListingViewModel

    @State private var selectedOption = 0
    
    init() {
        _subscriptionListingViewModel = StateObject(
            wrappedValue: SubscriptionListingViewModel(
                subscriptionListingRepository: SubscriptionListingRepository()
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            SegmentedPicker(selectedValue: $selectedOption, values: ["Subreddits", "Users", "Custom Feed"])
                .padding(4)

            ZStack {
                SubredditsView(subscriptionListingViewModel: subscriptionListingViewModel)
                    .opacity(selectedOption == 0 ? 1 : 0)
                
                UsersView(subscriptionListingViewModel: subscriptionListingViewModel)
                    .opacity(selectedOption == 1 ? 1 : 0)
                
                CustomFeedView(subscriptionListingViewModel: subscriptionListingViewModel)
                    .opacity(selectedOption == 2 ? 1 : 0)
            }

            Spacer()
        }
        .navigationTitle("Subscriptions")
        .task {
            await subscriptionListingViewModel.loadSubscriptionsOnline()
            await subscriptionListingViewModel.loadMyCustomFeedsOnline()
        }
        .onDisappear {
            subscriptionListingViewModel.cancelAllCancellables()
        }
    }
    
    struct SubredditsView: View {
        @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
        
        var body: some View {
            Group {
                if subscriptionListingViewModel.isLoadingSubscriptions {
                    ProgressIndicator()
                } else if subscriptionListingViewModel.subredditSubscriptions.isEmpty {
                    Text("No subscribed subreddits")
                } else {
                    List {
                        ForEach(subscriptionListingViewModel.subredditSubscriptions, id: \.fullName) { subscription in
                            HStack {
                                CustomWebImage(
                                    subscription.iconUrl,
                                    width: 30,
                                    height: 30,
                                    circleClipped: true,
                                    fallbackView: {
                                        SwiftUI.Image(systemName: "person.crop.circle")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                )
                                
                                Spacer()
                                    .frame(width: 16)
                                
                                Text(subscription.name)
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .listPlainItem()
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .themedList()
                }
            }
        }
    }

    struct UsersView: View {
        @EnvironmentObject var navigationManager: NavigationManager
        @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
        
        var body: some View {
            Group {
                if subscriptionListingViewModel.isLoadingSubscriptions {
                    ProgressIndicator()
                } else if subscriptionListingViewModel.userSubscriptions.isEmpty {
                    Text("No subscribed users")
                } else {
                    List {
                        ForEach(subscriptionListingViewModel.userSubscriptions, id: \.name) { subscription in
                            HStack {
                                CustomWebImage(
                                    subscription.iconUrl,
                                    width: 30,
                                    height: 30,
                                    circleClipped: true,
                                    fallbackView: {
                                        SwiftUI.Image(systemName: "person.crop.circle")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                )
                                
                                Spacer()
                                    .frame(width: 16)
                                
                                Text(subscription.name)
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .listPlainItem()
                            .onTapGesture {
                                navigationManager.path.append(AppNavigation.userDetails(username: subscription.name))
                            }
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .themedList()
                }
            }
        }
    }

    struct CustomFeedView: View {
        @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
        
        var body: some View {
            Group {
                if subscriptionListingViewModel.isLoadingMyCustomFeeds {
                    ProgressIndicator()
                } else if subscriptionListingViewModel.myCustomFeeds.isEmpty {
                    Text("No custom feeds")
                } else {
                    List {
                        ForEach(subscriptionListingViewModel.myCustomFeeds, id: \.path) { customFeed in
                            HStack {
                                CustomWebImage(
                                    customFeed.iconUrl,
                                    width: 30,
                                    height: 30,
                                    circleClipped: true,
                                    fallbackView: {
                                        SwiftUI.Image(systemName: "person.crop.circle")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                )
                                
                                Spacer()
                                    .frame(width: 16)
                                
                                Text(customFeed.displayName)
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .listPlainItem()
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .themedList()
                }
            }
        }
    }
}
