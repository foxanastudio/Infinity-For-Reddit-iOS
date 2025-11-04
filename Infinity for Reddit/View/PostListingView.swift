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
    @StateObject var postListingVideoManager: PostListingVideoManager = .init()
    @State private var showSortTypeKindSheet: Bool = false
    @State private var showSortTypeTimeSheet: Bool = false
    @State private var upcomingSortTypeKind: SortType.Kind?
    @State private var navigationBarMenuKey: UUID?
    @State private var showLayoutTypeSheet: Bool = false
    
    private let account: Account
    private let postListingMetadata: PostListingMetadata
    private var isSubredditPostListing: Bool = false
    private let handleToolbarMenu: Bool
    private let showFilterPostsOption: Bool
    private var isRootView: Bool = true
    
    init(account: Account,
         postListingMetadata: PostListingMetadata,
         externalPostFilter: PostFilter? = nil,
         handleToolbarMenu: Bool = true,
         showFilterPostsOption: Bool = true
    ) {
        self.account = account
        self.postListingMetadata = postListingMetadata
        if case .subreddit = postListingMetadata.postListingType {
            isSubredditPostListing = true
        }
        self.handleToolbarMenu = handleToolbarMenu
        self.showFilterPostsOption = showFilterPostsOption
        
        _postListingViewModel = StateObject(
            wrappedValue: PostListingViewModel(
                postListingMetadata: postListingMetadata,
                externalPostFilter: externalPostFilter,
                postListingRepository: PostListingRepository(),
                readPostsRepository: ReadPostsRepository(),
                postFeedID: postListingMetadata.getPostFeedID()
            )
        )
    }
    
    init(account: Account,
         postListingMetadata: PostListingMetadata,
         externalPostFilter: PostFilter? = nil,
         isRootView: Bool,
         showFilterPostsOption: Bool = true
    ) {
        self.account = account
        self.isRootView = isRootView
        self.postListingMetadata = postListingMetadata
        if case .subreddit = postListingMetadata.postListingType {
            isSubredditPostListing = true
        }
        self.handleToolbarMenu = false
        self.showFilterPostsOption = showFilterPostsOption
        
        _postListingViewModel = StateObject(
            wrappedValue: PostListingViewModel(
                postListingMetadata: postListingMetadata,
                externalPostFilter: externalPostFilter,
                postListingRepository: PostListingRepository(),
                readPostsRepository: ReadPostsRepository(),
                postFeedID: postListingMetadata.getPostFeedID()
            )
        )
    }
    
    var body: some View {
        RootView {
            if postListingViewModel.posts.isEmpty {
                ZStack {
                    if postListingViewModel.isInitialLoading || postListingViewModel.isInitialLoad {
                        ProgressIndicator()
                    } else {
                        Text("No posts")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                if isRootView {
                    List {
                        ForEach(postListingViewModel.posts, id: \.id) { post in
                            PostView(
                                account: account,
                                post: post,
                                layout: postListingViewModel.layout,
                                isSubredditPostListing: isSubredditPostListing,
                                onPostTypeTap: { onPostTypeClicked(post: post) },
                                onSensitiveTap: { onSensitiveClicked(post: post) }
                            )
                            .id(post.id)
                            .listPlainItemNoInsets()
                            .onAppear {
                                if post.subredditOrUserIcon == nil {
                                    Task {
                                        await postListingViewModel.loadIcon(post: post, displaySubredditIcon: !isSubredditPostListing)
                                    }
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
                    .refreshable {
                        await postListingViewModel.refreshPostsWithContinuation()
                    }
                } else {
                    ForEach(postListingViewModel.posts, id: \.id) { post in
                        PostView(
                            account: account,
                            post: post,
                            layout: postListingViewModel.layout,
                            isSubredditPostListing: isSubredditPostListing,
                            onPostTypeTap: { onPostTypeClicked(post: post) },
                            onSensitiveTap: { onSensitiveClicked(post: post) }
                        )
                        .id(post.id)
                        .listPlainItemNoInsets()
                        .onAppear {
                            if post.subredditOrUserIcon == nil {
                                Task {
                                    await postListingViewModel.loadIcon(post: post, displaySubredditIcon: !isSubredditPostListing)
                                }
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
        .applyIf(handleToolbarMenu) {
            $0.toolbar {
                NavigationBarMenu()
            }
        }
        .onChange(of: colorScheme) {
            //print(colorScheme == .dark)
        }
        .task(id: postListingViewModel.loadPostsTaskId) {
            await postListingViewModel.initialLoadPosts()
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            var options = [
                NavigationBarMenuItem(title: "Refresh") {
                    postListingViewModel.refreshPosts()
                },
                
                NavigationBarMenuItem(title: "Sort") {
                    showSortTypeKindSheet = true
                },
                
                NavigationBarMenuItem(title: "Change Post Layout") {
                    showLayoutTypeSheet = true
                }
            ]
            
            if showFilterPostsOption {
                options.append(NavigationBarMenuItem(title: "Filter Posts") {
                    navigationManager.path.append(
                        AppNavigation.filterPosts(
                            postListingMetadata: postListingMetadata
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
        .sheet(isPresented: $showSortTypeKindSheet) {
            SortTypeKindSheet(
                sortTypeKindSource: postListingMetadata.postListingType,
                currentSortTypeKind: postListingViewModel.sortType.type
            ) { sortTypeKind in
                if (sortTypeKind.hasTime) {
                    upcomingSortTypeKind = sortTypeKind
                    showSortTypeTimeSheet = true
                } else {
                    postListingViewModel.changeSortTypeKind(sortTypeKind)
                }
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSortTypeTimeSheet) {
            SortTypeTimeSheet(
                sortTypeTimeSource: postListingMetadata.postListingType,
                currentSortTypeTime: postListingViewModel.sortType.time
            ) { sortTypeTime in
                if let upcomingSortTypeKind = upcomingSortTypeKind {
                    postListingViewModel.changeSortType(SortType(type: upcomingSortTypeKind, time: sortTypeTime))
                }
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showLayoutTypeSheet) {
            LayoutTypeSheet(
                currentLayout: postListingViewModel.layout,
                onSelectLayout: { newLayout in
                    postListingViewModel.changePostLayout(to: newLayout)
                },
                onResetLayout: {
                    postListingViewModel.resetToDefaultLayout()
                }
            )
            .presentationDetents([.medium, .large])
        }
        .environment(\.postListingVideoManager, postListingVideoManager)
    }
    
    private func onPostTypeClicked(post: Post) {
        if showFilterPostsOption {
            navigationManager.path.append(
                AppNavigation.filteredPosts(
                    postListingMetadata: postListingMetadata,
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
                AppNavigation.filteredPosts(
                    postListingMetadata: postListingMetadata,
                    postFilter: postFilter
                )
            )
        }
    }
}
