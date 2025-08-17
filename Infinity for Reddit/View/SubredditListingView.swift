//
//  SubredditListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-19.
//

import SwiftUI

struct SubredditListingView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    
    @StateObject var subredditListingViewModel: SubredditListingViewModel
    @State private var showSortTypeKindSheet: Bool = false
    @State private var navigationBarMenuKey: UUID?
    private let account: Account
    
    init(account: Account, query: String) {
        self.account = account
        
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
                                subreddit.iconImg,
                                width: 40,
                                height: 40,
                                circleClipped: true,
                                handleImageTapGesture: false,
                                fallbackView: {
                                    SwiftUI.Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .frame(width: 40, height: 40)
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
                            navigationManager.path.append(AppNavigation.subredditDetails(subredditName: subreddit.displayName))
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
        .onChange(of: colorScheme) {
            //print(colorScheme == .dark)
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
