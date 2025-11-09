//
//  HistoryPostListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-03.
//

import SwiftUI
import Swinject
import GRDB
import Alamofire

struct HistoryPostListingView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    
    @StateObject var historyPostListingViewModel: HistoryPostListingViewModel
    @StateObject var postListingVideoManager: PostListingVideoManager = .init()
    @State private var navigationBarMenuKey: UUID?
    @State private var showLayoutTypeSheet: Bool = false

    private let historyPostListingMetadata: HistoryPostListingMetadata
    private let handleToolbarMenu: Bool
    private let showFilterPostsOption: Bool
    
    init(historyPostListingMetadata: HistoryPostListingMetadata,
         externalPostFilter: PostFilter? = nil,
         handleToolbarMenu: Bool = true,
         showFilterPostsOption: Bool = true
    ) {
        self.historyPostListingMetadata = historyPostListingMetadata
        self.handleToolbarMenu = handleToolbarMenu
        self.showFilterPostsOption = showFilterPostsOption
        
        _historyPostListingViewModel = StateObject(
            wrappedValue: HistoryPostListingViewModel(
                historyPostListingMetadata: historyPostListingMetadata,
                externalPostFilter: externalPostFilter,
                historyPostListingRepository: HistoryPostListingRepository(),
                historyPostsRepository: HistoryPostsRepository(),
                postFeedID: "read_posts"
            )
        )
    }
    
    var body: some View {
        RootView {
            if historyPostListingViewModel.posts.isEmpty {
                ZStack {
                    if historyPostListingViewModel.isInitialLoading || historyPostListingViewModel.isInitialLoad {
                        ProgressIndicator()
                    } else {
                        Text("No posts")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(historyPostListingViewModel.posts, id: \.id) { post in
                        PostView(
                            post: post,
                            postLayout: historyPostListingViewModel.postLayout,
                            isSubredditPostListing: false,
                            onPostTypeTap: {
                                onPostTypeClicked(post: post)
                            },
                            onSensitiveTap: {
                                onSensitiveClicked(post: post)
                            }
                        )
                        .id(ObjectIdentifier(post))
                        .listPlainItemNoInsets()
                        .onAppear {
                            if post.subredditOrUserIcon == nil {
                                Task {
                                    await historyPostListingViewModel.loadIcon(post: post)
                                }
                            }
                        }
                    }
                    if historyPostListingViewModel.hasMorePages {
                        ProgressIndicator()
                            .task {
                                await historyPostListingViewModel.loadPosts()
                            }
                            .listPlainItem()
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .themedList()
                .refreshable {
                    await historyPostListingViewModel.refreshPostsWithContinuation()
                }
            }
        }
        .applyIf(handleToolbarMenu) {
            $0.toolbar {
                NavigationBarMenu()
            }
        }
        .task(id: historyPostListingViewModel.loadPostsTaskId) {
            await historyPostListingViewModel.initialLoadPosts()
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            var options = [
                NavigationBarMenuItem(title: "Refresh") {
                    historyPostListingViewModel.refreshPosts()
                },
                
                NavigationBarMenuItem(title: "Change Post Layout") {
                    showLayoutTypeSheet = true
                }
            ]
            
            if showFilterPostsOption {
                options.append(NavigationBarMenuItem(title: "Filter Posts") {
                    navigationManager.path.append(
                        AppNavigation.filterHistoryPosts(
                            historyPostListingMetadata: historyPostListingMetadata
                        )
                    )
                })
            }
            
            navigationBarMenuKey = navigationBarMenuManager.push(options)
        }
        .onDisappear {
            guard let navigationBarMenuKey else { return }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
        .sheet(isPresented: $showLayoutTypeSheet) {
            PostLayoutSheet(
                currentPostLayout: historyPostListingViewModel.postLayout,
                onSelectPostLayout: { newLayout in
                    historyPostListingViewModel.changePostLayout(newLayout)
                }
            )
            .presentationDetents([.medium, .large])
        }
        .environment(\.postListingVideoManager, postListingVideoManager)
    }
    
    private func onPostTypeClicked(post: Post) {
        if showFilterPostsOption {
            navigationManager.path.append(
                AppNavigation.filteredHistoryPosts(
                    historyPostListingMetadata: historyPostListingMetadata,
                    postFilter: PostFilter.constructPostFilter(postType: post.postType)
                )
            )
        }
    }
    
    private func onSensitiveClicked(post: Post) {
        if showFilterPostsOption {
            var postFilter = PostFilter()
            postFilter.onlySensitive = true
            navigationManager.path.append(
                AppNavigation.filteredHistoryPosts(
                    historyPostListingMetadata: historyPostListingMetadata,
                    postFilter: postFilter
                )
            )
        }
    }
}
