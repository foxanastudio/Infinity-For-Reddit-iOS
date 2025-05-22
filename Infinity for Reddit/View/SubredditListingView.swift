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
                            
                            Text(subreddit.displayNamePrefixed)
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .listPlainItem()
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
