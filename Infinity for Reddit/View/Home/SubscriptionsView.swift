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

struct SubscriptionsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @StateObject var subscriptionListingViewModel: SubscriptionListingViewModel

    // State to track the selected picker index
    @State private var selectedOption = 0
    
    init() {
        _subscriptionListingViewModel = StateObject(
            wrappedValue: SubscriptionListingViewModel(
                subscriptionListingRepository: SubscriptionListingRepository()
            )
        )
    }

    var body: some View {
        VStack {
            Picker("Options", selection: $selectedOption) {
                Text("Subreddits").tag(0)
                Text("Users").tag(1)
                Text("Custom Feed").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedOption == 0 {
                SubredditsView(subscriptionListingViewModel: subscriptionListingViewModel)
            } else if selectedOption == 1 {
                UsersView(subscriptionListingViewModel: subscriptionListingViewModel)
            } else {
                CustomFeedView(subscriptionListingViewModel: subscriptionListingViewModel)
            }

            Spacer() // Push content to the top
        }
        .navigationTitle("Subscriptions")
        .onAppear {
            subscriptionListingViewModel.loadSubscriptionsOnline()
            subscriptionListingViewModel.loadMyCustomFeedsOnline()
        }
    }
    
    struct SubredditsView: View {
        @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
        
        var body: some View {
            Group {
                if subscriptionListingViewModel.isLoadingSubscriptions {
                    Text("Is loading")
                } else if subscriptionListingViewModel.subredditSubscriptions.isEmpty {
                    Text("No subscribed subreddits")
                } else {
                    List {
                        ForEach(subscriptionListingViewModel.subredditSubscriptions, id: \.fullName) { subscription in
                            Text(subscription.name)
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
        @ObservedObject var subscriptionListingViewModel: SubscriptionListingViewModel
        
        var body: some View {
            Group {
                if subscriptionListingViewModel.isLoadingSubscriptions {
                    Text("Is loading")
                } else if subscriptionListingViewModel.userSubscriptions.isEmpty {
                    Text("No subscribed users")
                } else {
                    List {
                        ForEach(subscriptionListingViewModel.userSubscriptions, id: \.name) { subscription in
                            Text(subscription.name)
                                .listPlainItem()
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
                    Text("Is loading")
                } else if subscriptionListingViewModel.myCustomFeeds.isEmpty {
                    Text("No custom feeds")
                } else {
                    List {
                        ForEach(subscriptionListingViewModel.myCustomFeeds, id: \.path) { customFeed in
                            Text(customFeed.displayName)
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
