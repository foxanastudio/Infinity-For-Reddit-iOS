//
//  SubredditListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-19.
//

import SwiftUI

struct SubredditListingView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    
    @StateObject var subredditListingViewModel: SubredditListingViewModel
    @State private var showSortTypeKindSheet: Bool = false
    @State private var navigationBarMenuKey: UUID?
    private let account: Account
    private let iconSize: CGFloat = 28
    private var onSelect: ((Subreddit) -> Void)?
    
    init(account: Account, query: String, onSelect: ((Subreddit) -> Void)? = nil) {
        self.account = account
        self.onSelect = onSelect
        
        _subredditListingViewModel = StateObject(
            wrappedValue: SubredditListingViewModel(
                query: query,
                subredditListingRepository: SubredditListingRepository()
            )
        )
    }
    
    var body: some View {
        Group {
            if subredditListingViewModel.isInitialLoading || subredditListingViewModel.isInitialLoad {
                ProgressIndicator()
            } else if subredditListingViewModel.subreddits.isEmpty {
                Text("No subreddits")
            } else {
                List {
                    ForEach(subredditListingViewModel.subreddits, id: \.id) { subreddit in
                        HStack {
                            CustomWebImage(
                                subreddit.iconUrl,
                                width: iconSize,
                                height: iconSize,
                                circleClipped: true,
                                handleImageTapGesture: false,
                                fallbackView: {
                                    InitialLetterAvatarImageFallbackView(name: subreddit.displayName, size: iconSize)
                                }
                            )
                            
                            Spacer()
                                .frame(width: 24)
                            
                            VStack {
                                Text(subreddit.displayNamePrefixed)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .primaryText()
                                
                                Text("Subscribers: " + subreddit.subscribers.formatted())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .secondaryText()
                            }
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .listPlainItem()
                        .onTapGesture {
                            if let onSelect {
                                onSelect(subreddit)
                            } else {
                                navigationManager.path.append(
                                    AppNavigation.subredditDetails(subredditName: subreddit.displayName)
                                )
                            }
                        }
                    }
                    if subredditListingViewModel.hasMorePages {
                        ProgressIndicator()
                            .task {
                                await subredditListingViewModel.loadSubreddits()
                            }
                            .listPlainItem()
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .themedList()
            }
        }
        .task(id: subredditListingViewModel.loadSubredditsTaskId) {
            await subredditListingViewModel.initialLoadSubreddits()
        }
        .refreshable {
            await subredditListingViewModel.refreshSubredditsWithContinuation()
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Refresh") {
                    subredditListingViewModel.refreshSubreddits()
                },
                
                NavigationBarMenuItem(title: "Sort") {
                    showSortTypeKindSheet = true
                }
            ])
        }
        .onDisappear {
            guard let navigationBarMenuKey else { return }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
        .sheet(isPresented: $showSortTypeKindSheet) {
            SortTypeKindSheet(
                sortTypeKindSource: OtherSortTypeKindSource.subredditListing,
                currentSortTypeKind: subredditListingViewModel.sortType
            ) { sortTypeKind in
                subredditListingViewModel.changeSortTypeKind(sortTypeKind)
            }
            .presentationDetents([.medium, .large])
        }
    }
}
