//
//  AnonymousSubscriptionsView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-08.
//

import SwiftUI
import Swinject
import GRDB
import Alamofire

struct AnonymousSubscriptionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @StateObject var anonymousSubscriptionListingViewModel: AnonymousSubscriptionListingViewModel
    
    @FocusState private var focusedField: FieldType?

    @State private var selectedOption = 0
    @State private var navigationBarMenuKey: UUID?
    @State private var searchQuery: String = ""
    @State private var keyboardId: UUID = UUID()
    
    init(subscriptionSelectionMode: ThingSelectionMode = .noSelection) {
        _anonymousSubscriptionListingViewModel = StateObject(
            wrappedValue: AnonymousSubscriptionListingViewModel(
                subscriptionSelectionMode: subscriptionSelectionMode,
                anonymousSubscriptionListingRepository: AnonymousSubscriptionListingRepository()
            )
        )
    }

    var body: some View {
        RootView {
            VStack(spacing: 0) {
                switch anonymousSubscriptionListingViewModel.subscriptionSelectionMode {
                case .noSelection:
                    SegmentedPicker(
                        selectedValue: $selectedOption,
                        values: ["Subreddits", "Users", "Custom Feed"]
                    )
                    .padding(4)
                case .subredditMultiSelection:
                    EmptyView()
                case .userMultiSelection:
                    EmptyView()
                default:
                    SegmentedPicker(
                        selectedValue: $selectedOption,
                        values: ["Subreddits", "Users"]
                    )
                    .padding(4)
                }
                
                HStack(spacing: 8) {
                    SwiftUI.Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    CustomTextField("Search",
                                    text: $searchQuery,
                                    singleLine: true,
                                    autocapitalization: .never,
                                    showBorder: false,
                                    showBackground: false,
                                    fieldType: FieldType.search,
                                    focusedField: $focusedField)
                    .id(keyboardId)
                    .padding(16)
                    .submitLabel(.search)
                }
                .padding(.leading, 12)
                .background(Color(hex: customThemeViewModel.currentCustomTheme.filledCardViewBackgroundColor))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                
                ZStack {
                    switch anonymousSubscriptionListingViewModel.subscriptionSelectionMode {
                    case .noSelection:
                        AnonymousSubscribedSubredditListingView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                            .opacity(selectedOption == 0 ? 1 : 0)
                            .allowsHitTesting(selectedOption == 0)
                        
                        AnonymousSubscribedUserListingView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                            .opacity(selectedOption == 1 ? 1 : 0)
                            .allowsHitTesting(selectedOption == 1)
                        
                        AnonymousCustomFeedView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                            .opacity(selectedOption == 2 ? 1 : 0)
                            .allowsHitTesting(selectedOption == 2)
                    case .thingSelection(let onSelectThing):
                        AnonymousSubscribedSubredditListingView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel) { subscribedSubredditData in
                            onSelectThing(Thing.subscribedSubreddit(subscribedSubredditData))
                        }
                        .opacity(selectedOption == 0 ? 1 : 0)
                        .allowsHitTesting(selectedOption == 0)
                        
                        AnonymousSubscribedUserListingView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel) { subscribedUserData in
                            onSelectThing(Thing.subscribedUser(subscribedUserData))
                        }
                        .opacity(selectedOption == 1 ? 1 : 0)
                        .allowsHitTesting(selectedOption == 1)
                    case .subredditAndUserMultiSelection:
                        AnonymousSubscribedSubredditListingMultiSelectionView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                            .opacity(selectedOption == 0 ? 1 : 0)
                            .allowsHitTesting(selectedOption == 0)
                        
                        AnonymousSubscribedUserListingMultiSelectionView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                            .opacity(selectedOption == 1 ? 1 : 0)
                            .allowsHitTesting(selectedOption == 1)
                    case .subredditMultiSelection:
                        AnonymousSubscribedSubredditListingMultiSelectionView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                            .opacity(selectedOption == 0 ? 1 : 0)
                            .allowsHitTesting(selectedOption == 0)
                    case .userMultiSelection:
                        AnonymousSubscribedUserListingMultiSelectionView(anonymousSubscriptionListingViewModel: anonymousSubscriptionListingViewModel)
                            .opacity(selectedOption == 0 ? 1 : 0)
                            .allowsHitTesting(selectedOption == 0)
                    }
                }
                
                switch anonymousSubscriptionListingViewModel.subscriptionSelectionMode {
                case .subredditAndUserMultiSelection(_, let onConfirmSelection):
                    Button {
                        onConfirmSelection(anonymousSubscriptionListingViewModel.getSelectedSubredditsAndUsers())
                        dismiss()
                    } label: {
                        HStack {
                            Text("Done")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(16)
                    .filledButton()
                case .subredditMultiSelection(_, let onConfirmSelection):
                    Button {
                        onConfirmSelection(anonymousSubscriptionListingViewModel.getSelectedSubreddits())
                        dismiss()
                    } label: {
                        HStack {
                            Text("Done")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(16)
                    .filledButton()
                case .userMultiSelection(_, let onConfirmSelection):
                    Button {
                        onConfirmSelection(anonymousSubscriptionListingViewModel.getSelectedUsers())
                        dismiss()
                    } label: {
                        HStack {
                            Text("Done")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(16)
                    .filledButton()
                default:
                    EmptyView()
                }
                
                KeyboardToolbar {
                    focusedField = nil
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

                    searchQuery = ""
                }
            }
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Create Custom Feed") {
                    navigationManager.append(AppNavigation.createCustomFeed)
                }
            ])
        }
        .onDisappear {
            keyboardId = UUID()
            
            guard let navigationBarMenuKey else {
                return
            }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
        .onChange(of: searchQuery) { _, newValue in
            anonymousSubscriptionListingViewModel.setSearchQuery(newValue)
        }
    }

    struct AnonymousCustomFeedView: View {
        @EnvironmentObject var navigationManager: NavigationManager
        @ObservedObject var anonymousSubscriptionListingViewModel: AnonymousSubscriptionListingViewModel
        
        var body: some View {
            RootView {
                if anonymousSubscriptionListingViewModel.myCustomFeeds.isEmpty {
                    ZStack {
                        Text("No custom feeds")
                            .primaryText()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        if !anonymousSubscriptionListingViewModel.favoriteMyCustomFeeds.isEmpty {
                            StaticListSection("Favorite")
                            
                            ForEach(anonymousSubscriptionListingViewModel.favoriteMyCustomFeeds, id: \.path) { customFeed in
                                SubscriptionItemView(text: customFeed.displayName, iconUrl: customFeed.iconUrl, isFavorite: customFeed.isFavorite, action: {
                                    navigationManager.append(AppNavigation.customFeed(customFeed: .myCustomFeed(customFeed)))
                                }) {
                                    customFeed.isFavorite.toggle()
                                    anonymousSubscriptionListingViewModel.toggleFavoriteCustomFeed(customFeed)
                                }
                                .limitedWidth()
                                .id(ObjectIdentifier(customFeed))
                                .listPlainItemNoInsets()
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            await anonymousSubscriptionListingViewModel.deleteCustomFeed(customFeed)
                                        }
                                    } label: {
                                        Text("Delete")
                                            .foregroundStyle(.white)
                                    }
                                    .tint(.red)
                                }
                            }
                        }
                        
                        if !anonymousSubscriptionListingViewModel.favoriteMyCustomFeeds.isEmpty {
                            StaticListSection("All")
                        }
                        
                        ForEach(anonymousSubscriptionListingViewModel.myCustomFeeds, id: \.path) { customFeed in
                            SubscriptionItemView(text: customFeed.displayName, iconUrl: customFeed.iconUrl, isFavorite: customFeed.isFavorite, action: {
                                navigationManager.append(AppNavigation.customFeed(customFeed: .myCustomFeed(customFeed)))
                            }) {
                                customFeed.isFavorite.toggle()
                                anonymousSubscriptionListingViewModel.toggleFavoriteCustomFeed(customFeed)
                            }
                            .limitedWidth()
                            .id(ObjectIdentifier(customFeed))
                            .listPlainItemNoInsets()
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task {
                                        await anonymousSubscriptionListingViewModel.deleteCustomFeed(customFeed)
                                    }
                                } label: {
                                    Text("Delete")
                                        .foregroundStyle(.white)
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .themedList()
                }
            }
        }
    }
}

private enum FieldType: Hashable {
    case search
}
