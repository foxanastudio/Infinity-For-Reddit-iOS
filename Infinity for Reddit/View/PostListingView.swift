//
//  PostListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-04.
//

import SwiftUI
import Swinject
import GRDB
import Alamofire

struct PostListingView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    @StateObject var postListingViewModel: PostListingViewModel
    @State private var isRootView: Bool = true
    @State private var showNewPostMenu: Bool = false
    
    private let account: Account
    private var isSubredditPostListing: Bool = false
    
    init(account: Account, postListingMetadata: PostListingMetadata) {
        self.account = account
        if case .subreddit = postListingMetadata.postListingType {
            isSubredditPostListing = true
        }
        
        _postListingViewModel = StateObject(
            wrappedValue: PostListingViewModel(
                postListingMetadata: postListingMetadata,
                postListingRepository: PostListingRepository()
            )
        )
    }
    
    init(account: Account, postListingMetadata: PostListingMetadata, isRootView: Bool) {
        self.account = account
        self.isRootView = isRootView
        if case .subreddit = postListingMetadata.postListingType {
            isSubredditPostListing = true
        }
        
        _postListingViewModel = StateObject(
            wrappedValue: PostListingViewModel(
                postListingMetadata: postListingMetadata,
                postListingRepository: PostListingRepository()
            )
        )
    }
    
    var body: some View {
        Group {
            if postListingViewModel.isInitialLoading || postListingViewModel.isInitialLoad {
                ProgressIndicator()
            } else if postListingViewModel.posts.isEmpty {
                Text("No posts")
            } else {
                if isRootView {
                    List {
                        ForEach(postListingViewModel.posts, id: \.id) { post in
                            PostViewCard(account: account, post: post, isSubredditPostListing: isSubredditPostListing)
                                .id(post.id)
                                .listPlainItemNoInsets()
                                .onAppear {
                                    Task {
                                        await postListingViewModel.loadIcon(post: post, displaySubredditIcon: !isSubredditPostListing)
                                    }
                                }
                        }
                        if postListingViewModel.hasMorePages {
                            ProgressIndicator()
                                .task {
                                    await postListingViewModel.loadPosts()
                                }
                                .listPlainItem()
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .themedList()
                } else {
                    ForEach(postListingViewModel.posts, id: \.id) { post in
                        PostViewCard(account: account, post: post, isSubredditPostListing: isSubredditPostListing)
                            .id(post.id)
                            .listPlainItemNoInsets()
                            .onAppear {
                                Task {
                                    await postListingViewModel.loadIcon(post: post, displaySubredditIcon: !isSubredditPostListing)
                                }
                            }
                    }
                    if postListingViewModel.hasMorePages {
                        ProgressIndicator()
                            .task {
                                await postListingViewModel.loadPosts()
                            }
                            .listPlainItem()
                    }
                }
            }
        }
        .onChange(of: colorScheme) {
            //print(colorScheme == .dark)
        }
        .task {
            await postListingViewModel.initialLoadPosts()
        }
        .onAppear {
            navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "New Post") {
                    showNewPostMenu = true
                },
                
                NavigationBarMenuItem(title: "Sort") {
                    print("sort")
                }
            ])
        }
        .onDisappear {
            navigationBarMenuManager.pop()
        }
        .sheet(isPresented: $showNewPostMenu) {
            NewPostSheet()
                .themedList()
                .presentationDetents([.fraction(0.33)])
                .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.primaryTextColor))
        }
    }
}
