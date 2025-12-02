//
//  PostListingTestView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-18.
//

import SwiftUI
import Swinject
import GRDB
import Alamofire

struct PostListingTestView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    @StateObject var postListingViewModel: PostListingViewModel
    @State private var isRootView: Bool = true
    @State private var showSortTypeKindSheet: Bool = false
    @State private var showSortTypeTimeSheet: Bool = false
    @State private var upcomingSortTypeKind: SortType.Kind?
    @State private var navigationBarMenuKey: UUID?
    
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.sensitiveContentKey, store: .contentSensitivityFilter) private var sensitiveContent: Bool = false
    
    private let account: Account
    private let postListingMetadata: PostListingMetadata
    private var isSubredditPostListing: Bool = false
    private let handleToolbarMenu: Bool
    
    init(account: Account, postListingMetadata: PostListingMetadata, handleToolbarMenu: Bool = true) {
        self.account = account
        self.postListingMetadata = postListingMetadata
        if case .subreddit = postListingMetadata.postListingType {
            isSubredditPostListing = true
        }
        self.handleToolbarMenu = handleToolbarMenu
        
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
        self.postListingMetadata = postListingMetadata
        if case .subreddit = postListingMetadata.postListingType {
            isSubredditPostListing = true
        }
        self.handleToolbarMenu = false
        
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
            if postListingViewModel.posts.isEmpty {
                if postListingViewModel.isInitialLoading || postListingViewModel.isInitialLoad {
                    ProgressIndicator()
                } else {
                    Text("No posts")
                }
            } else {
                if isRootView {
//                    MultiColumnList(
//                        items: postListingViewModel.itemsWithLoadingIndicator,
//                        numberOfColumns: 1,
//                        viewForItem: { item, width in
//                            switch item {
//                            case .post(let post):
//                                return AnyView(
//                                    PostViewCard(account: account, post: post, isSubredditPostListing: isSubredditPostListing, width: width)
//                                        .id(post.id)
//                                        .listPlainItemNoInsets()
//                                        .onAppear {
//                                            if post.subredditOrUserIcon == nil {
//                                                Task {
//                                                    await postListingViewModel.loadIcon(post: post, displaySubredditIcon: !isSubredditPostListing)
//                                                }
//                                            }
//                                        }
//                                )
//                            case .loading:
//                                return AnyView(
//                                    ProgressIndicator()
//                                        .id("loadingIndicator")
//                                )
//                            }
//                        },
//                        onItemAppear: { index, item in
//                            postListingViewModel.loadPostsPagination(index: index)
//                        }
//                    )
                }
            }
        }
        .applyIf(handleToolbarMenu) {
            $0.toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationBarMenu()
                }
            }
        }
        .onChange(of: colorScheme) {
            //print(colorScheme == .dark)
        }
        .task(id: postListingViewModel.loadPostsTaskId) {
            await postListingViewModel.initialLoadPosts(saveLastSeenPostInFrontPage: false)
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Refresh") {
                    postListingViewModel.refreshPosts()
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
        .onChange(of: sensitiveContent) { oldValue, newValue in
            postListingViewModel.setSensitiveContent(newValue)
        }
        .wrapContentSheet(isPresented: $showSortTypeKindSheet) {
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
        }
        .wrapContentSheet(isPresented: $showSortTypeTimeSheet) {
            SortTypeTimeSheet(
                sortTypeTimeSource: postListingMetadata.postListingType,
                currentSortTypeTime: postListingViewModel.sortType.time
            ) { sortTypeTime in
                if let upcomingSortTypeKind = upcomingSortTypeKind {
                    postListingViewModel.changeSortType(SortType(type: upcomingSortTypeKind, time: sortTypeTime))
                }
            }
        }
    }
}
