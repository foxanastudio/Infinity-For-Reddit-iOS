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
    
    @StateObject var subredditListingViewModel: SubredditListingViewModel
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
        .task {
            await subredditListingViewModel.initialLoadSubreddits()
        }
    }
}
