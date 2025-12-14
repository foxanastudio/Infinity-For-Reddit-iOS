//
//  SubredditListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-19.
//

import SwiftUI

struct SubredditListingView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @ObservedObject var subredditListingViewModel: SubredditListingViewModel
    @State private var showSortTypeKindSheet: Bool = false
    @State private var navigationBarMenuKey: UUID?
    private let account: Account
    private let iconSize: CGFloat = 28
    
    init(account: Account, subredditListingViewModel: SubredditListingViewModel) {
        self.account = account
        self.subredditListingViewModel = subredditListingViewModel
    }
    
    var body: some View {
        RootView {
            if subredditListingViewModel.subreddits.isEmpty {
                ZStack {
                    if subredditListingViewModel.isInitialLoading {
                        ProgressIndicator()
                    } else if subredditListingViewModel.isInitialLoad, let error = subredditListingViewModel.error {
                        Text("Unable to load subreddits. Tap to retry. Error: \(error.localizedDescription)")
                            .primaryText()
                            .padding(16)
                            .onTapGesture {
                                subredditListingViewModel.refreshSubreddits()
                            }
                    } else {
                        Text("No subreddits")
                            .primaryText()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(subredditListingViewModel.subreddits, id: \.id) { subreddit in
                        HStack(spacing: 0) {
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
                            
                            VStack(spacing: 0) {
                                Text(subreddit.displayNamePrefixed)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .primaryText()
                                
                                Text("Subscribers: " + subreddit.subscribers.formatted())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .secondaryText()
                            }
                            
                            Spacer()
                            
                            if subredditListingViewModel.thingSelectionMode.isMultiSelection {
                                SwiftUI.Image(systemName: isSelected(subreddit) ? "checkmark.square" : "square")
                                    .primaryIcon()
                            }
                        }
                        .listPlainItemNoInsets()
                        .padding(16)
                        .background(isSelected(subreddit) ? Color(hex: customThemeViewModel.currentCustomTheme.filledCardViewBackgroundColor) : Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            switch subredditListingViewModel.thingSelectionMode {
                            case .noSelection:
                                navigationManager.append(
                                    AppNavigation.subredditDetails(subredditName: subreddit.displayName)
                                )
                            case .thingSelection(let onSelectThing):
                                onSelectThing(.subreddit(subreddit.toSubredditData()))
                                dismiss()
                            case .subredditAndUserMultiSelection:
                                subredditListingViewModel.toggleSelection(subreddit: subreddit)
                            case .subredditMultiSelection:
                                subredditListingViewModel.toggleSelection(subreddit: subreddit)
                            case .userMultiSelection(selectedUsers: let selectedUsers, onConfirmSelection: let onConfirmSelection):
                                // Shouldn't happen
                                break
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
                .showErrorUsingSnackbar(subredditListingViewModel.$error)
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
        .wrapContentSheet(isPresented: $showSortTypeKindSheet) {
            SortTypeKindSheet(
                sortTypeKindSource: OtherSortTypeKindSource.subredditListing,
                currentSortTypeKind: subredditListingViewModel.sortType
            ) { sortTypeKind in
                subredditListingViewModel.changeSortTypeKind(sortTypeKind)
            }
        }
    }
    
    func isSelected(_ subreddit: Subreddit) -> Bool {
        return subredditListingViewModel.selectedSubreddits.index(id: subreddit.id) != nil
        || subredditListingViewModel.selectedSubredditData.index(id: subreddit.id) != nil
        || subredditListingViewModel.selectedSubscribedSubreddits.index(id: subreddit.id) != nil
        || subredditListingViewModel.selectedSubredditsInCustomFeed.index(id: subreddit.name) != nil
    }
}
