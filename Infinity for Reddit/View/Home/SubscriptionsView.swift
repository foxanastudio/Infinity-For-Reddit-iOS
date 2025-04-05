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
                            HStack {
                                if let iconUrl = subscription.iconUrl, iconUrl.count > 0 {
                                    WebImage(url: URL(string: iconUrl)) { image in
                                        image
                                            .resizable()
                                            
                                    }  placeholder: {
                                        
                                    }
                                    .onSuccess { image, data, cacheType in
                                        // Success
                                        // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                                    }
                                    .indicator(.activity)
                                    .clipShape(Circle())
                                    .transition(.fade(duration: 0.5))
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                } else {
                                    SwiftUI.Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                                
                                Spacer()
                                    .frame(width: 16)
                                
                                Text(subscription.name)
                            }
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
                    Text("Is loading")
                } else if subscriptionListingViewModel.userSubscriptions.isEmpty {
                    Text("No subscribed users")
                } else {
                    List {
                        ForEach(subscriptionListingViewModel.userSubscriptions, id: \.name) { subscription in
                            HStack {
                                if let iconUrl = subscription.iconUrl, iconUrl.count > 0 {
                                    WebImage(url: URL(string: iconUrl)) { image in
                                        image
                                            .resizable()
                                            
                                    }  placeholder: {
                                        
                                    }
                                    .onSuccess { image, data, cacheType in
                                        // Success
                                        // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                                    }
                                    .indicator(.activity)
                                    .clipShape(Circle())
                                    .transition(.fade(duration: 0.5))
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                } else {
                                    SwiftUI.Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                                
                                Spacer()
                                    .frame(width: 16)
                                
                                Text(subscription.name)
                            }
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
                    Text("Is loading")
                } else if subscriptionListingViewModel.myCustomFeeds.isEmpty {
                    Text("No custom feeds")
                } else {
                    List {
                        ForEach(subscriptionListingViewModel.myCustomFeeds, id: \.path) { customFeed in
                            HStack {
                                if let iconUrl = customFeed.iconUrl, iconUrl.count > 0 {
                                    WebImage(url: URL(string: iconUrl)) { image in
                                        image
                                            .resizable()
                                            
                                    }  placeholder: {
                                        
                                    }
                                    .onSuccess { image, data, cacheType in
                                        // Success
                                        // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                                    }
                                    .indicator(.activity)
                                    .clipShape(Circle())
                                    .transition(.fade(duration: 0.5))
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                } else {
                                    SwiftUI.Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                                
                                Spacer()
                                    .frame(width: 16)
                                
                                Text(customFeed.displayName)
                            }
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
