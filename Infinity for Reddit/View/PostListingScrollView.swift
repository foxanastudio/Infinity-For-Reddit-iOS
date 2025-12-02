//
//  PostListingScrollView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-04.
//

import SwiftUI
import Swinject
import GRDB
import Alamofire

struct PostListingScrollView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    
    @StateObject var postListingViewModel: PostListingViewModel
    @State private var isRootView: Bool = true
    @State private var navigationBarMenuKey: UUID?
    
    private let account: Account
    
    init(account: Account, postListingMetadata: PostListingMetadata) {
        self.account = account
        
        _postListingViewModel = StateObject(
            wrappedValue: PostListingViewModel(
                postListingMetadata: postListingMetadata,
                externalPostFilter: nil,
                postListingRepository: PostListingRepository(),
                historyPostsRepository: HistoryPostsRepository(),
                thingModerationRepository: ThingModerationRepository()
            )
        )
    }
    
    init(account: Account, postListingMetadata: PostListingMetadata, isRootView: Bool) {
        self.account = account
        self.isRootView = isRootView
        
        _postListingViewModel = StateObject(
            wrappedValue: PostListingViewModel(
                postListingMetadata: postListingMetadata,
                externalPostFilter: nil,
                postListingRepository: PostListingRepository(),
                historyPostsRepository: HistoryPostsRepository(),
                thingModerationRepository: ThingModerationRepository()
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
                            PostView(
                                post: post,
                                postLayout: postListingViewModel.postLayout,
                                isSubredditPostListing: false,
                                onPostTypeTap: { },
                                onSensitiveTap: { },
                                onLongPressPost: { },
                                onShare: { }
                            )
                            .id(ObjectIdentifier(post))
                            .listPlainItemNoInsets()
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
                        PostView(
                            post: post,
                            postLayout: postListingViewModel.postLayout,
                            isSubredditPostListing: false,
                            onPostTypeTap: { },
                            onSensitiveTap: { },
                            onLongPressPost: { },
                            onShare: { }
                        )
                        .id(ObjectIdentifier(post))
                        .listPlainItemNoInsets()
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
            await postListingViewModel.initialLoadPosts(saveLastSeenPostInFrontPage: false)
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "New Post") {
                    print("new post")
                },
                
                NavigationBarMenuItem(title: "Sort") {
                    print("sort")
                }
            ])
        }
        .onDisappear {
            guard let navigationBarMenuKey else { return }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
    }
}
