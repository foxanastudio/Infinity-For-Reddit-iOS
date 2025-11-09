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
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    
    @StateObject var postListingViewModel: PostListingViewModel
    @StateObject var postListingVideoManager: PostListingVideoManager = .init()
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var showSortTypeKindSheet: Bool = false
    @State private var showSortTypeTimeSheet: Bool = false
    @State private var upcomingSortTypeKind: SortType.Kind?
    @State private var navigationBarMenuKey: UUID?
    @State private var showLayoutTypeSheet: Bool = false
    @State var lazyMode: Task<Void, Error>?
    @State var lazyModeState: LazyModeState = .stopped
    
    private let postListingMetadata: PostListingMetadata
    private var isSubredditPostListing: Bool = false
    private let handleToolbarMenu: Bool
    private let showFilterPostsOption: Bool
    private var isRootView: Bool = true
    private var pauseLazyModeExternalFlag: Bool = false
    private var onStartLazyMode: (() -> Void)?
    private var onStopLazyMode: (() -> Void)?
    
    init(postListingMetadata: PostListingMetadata,
         externalPostFilter: PostFilter? = nil,
         handleToolbarMenu: Bool = true,
         showFilterPostsOption: Bool = true
    ) {
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
                historyPostsRepository: HistoryPostsRepository()
            )
        )
    }
    
    init(postListingMetadata: PostListingMetadata,
         externalPostFilter: PostFilter? = nil,
         isRootView: Bool,
         showFilterPostsOption: Bool = true,
         scrollProxy: ScrollViewProxy? = nil,
         pauseLazyModeExternalFlag: Bool,
         onStartLazyMode: (() -> Void)? = nil,
         onStopLazyMode: (() -> Void)? = nil
    ) {
        self.isRootView = isRootView
        self.postListingMetadata = postListingMetadata
        if case .subreddit = postListingMetadata.postListingType {
            isSubredditPostListing = true
        }
        self.handleToolbarMenu = false
        self.showFilterPostsOption = showFilterPostsOption
        self.scrollProxy = scrollProxy
        self.pauseLazyModeExternalFlag = pauseLazyModeExternalFlag
        self.onStartLazyMode = onStartLazyMode
        self.onStopLazyMode = onStopLazyMode
        
        _postListingViewModel = StateObject(
            wrappedValue: PostListingViewModel(
                postListingMetadata: postListingMetadata,
                externalPostFilter: externalPostFilter,
                postListingRepository: PostListingRepository(),
                historyPostsRepository: HistoryPostsRepository()
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
                    ScrollViewReader { proxy in
                        List {
                            ForEach(postListingViewModel.posts, id: \.id) { post in
                                PostView(
                                    post: post,
                                    postLayout: postListingViewModel.postLayout,
                                    isSubredditPostListing: isSubredditPostListing,
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
                                    postListingViewModel.insertIntoAppearedPosts(post)
                                    
                                    if post.subredditOrUserIcon == nil {
                                        Task {
                                            await postListingViewModel.loadIcon(post: post, displaySubredditIcon: !isSubredditPostListing)
                                        }
                                    }
                                }
                                .onDisappear {
                                    postListingViewModel.appearedPosts.removeAll {
                                        $0.id == post.id
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
                        .onAppear {
                            scrollProxy = proxy
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if lazyModeState == .started {
                                        pauseLazyMode(resetScrolledPost: true)
                                    }
                                }
                                .onEnded { value in
                                    if lazyModeState == .paused {
                                        resumeLazyMode()
                                    }
                                }
                        )
                    }
                } else {
                    ForEach(postListingViewModel.posts, id: \.id) { post in
                        PostView(
                            post: post,
                            postLayout: postListingViewModel.postLayout,
                            isSubredditPostListing: isSubredditPostListing,
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
                            postListingViewModel.insertIntoAppearedPosts(post)
                            
                            if post.subredditOrUserIcon == nil {
                                Task {
                                    await postListingViewModel.loadIcon(post: post, displaySubredditIcon: !isSubredditPostListing)
                                }
                            }
                        }
                        .onDisappear {
                            postListingViewModel.appearedPosts.removeAll {
                                $0.id == post.id
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
        .task(id: postListingViewModel.loadPostsTaskId) {
            await postListingViewModel.initialLoadPosts()
        }
        .onAppear {
            if lazyModeState == .paused {
                resumeLazyMode()
            }
            
            setUpMenu()
        }
        .onDisappear {
            if lazyModeState == .started {
                pauseLazyMode(resetScrolledPost: false)
            }
            
            guard let navigationBarMenuKey else { return }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
        .appForegroundBackgroundListener(
            onAppEntersForeground: {
                if lazyModeState == .paused {
                    resumeLazyMode()
                }
            }, onAppEntersBackground: {
                if lazyModeState == .started {
                    pauseLazyMode(resetScrolledPost: false)
                }
            }
        )
        .onChange(of: lazyModeState) {
            setUpMenu()
        }
        .onChange(of: pauseLazyModeExternalFlag) { _, newValue in
            if newValue {
                if lazyModeState == .started {
                    pauseLazyMode(resetScrolledPost: false)
                }
            } else {
                if lazyModeState == .paused {
                    resumeLazyMode()
                }
            }
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
            PostLayoutSheet(
                currentPostLayout: postListingViewModel.postLayout,
                onSelectPostLayout: { newLayout in
                    postListingViewModel.changePostLayout(newLayout)
                }
            )
            .presentationDetents([.medium, .large])
        }
        .environment(\.postListingVideoManager, postListingVideoManager)
    }
    
    private func setUpMenu() {
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
            },
            
            NavigationBarMenuItem(title: lazyModeState == .stopped ? "Start Lazy Mode" : "Stop Lazy Mode") {
                if lazyModeState == .stopped {
                    startLazyMode()
                } else {
                    stopLazyMode()
                }
            },
            
            NavigationBarMenuItem(title: "Hide Read Posts") {
                postListingViewModel.hideReadPosts()
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
    
    private func startLazyMode() {
        guard lazyMode == nil else {
            return
        }
        
        onStartLazyMode?()
        
        lazyModeState = .started
        
        if postListingViewModel.lazyModeScrolledPost == nil {
            if !postListingViewModel.appearedPosts.isEmpty {
                postListingViewModel.lazyModeScrolledPost = postListingViewModel.appearedPosts[0]
            } else if !postListingViewModel.posts.isEmpty {
                postListingViewModel.lazyModeScrolledPost = postListingViewModel.posts[0]
            }
        }
        
        lazyMode = Task {
            repeat {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run {
                    if Task.isCancelled {
                        return
                    }
                    
                    if let scrollProxy = scrollProxy, !postListingViewModel.posts.isEmpty {
                        if let scrolledParent = postListingViewModel.lazyModeScrolledPost {
                            if let index = postListingViewModel.posts.index(id: scrolledParent.id) {
                                if index < postListingViewModel.posts.count {
                                    postListingViewModel.lazyModeScrolledPost = postListingViewModel.posts[index + 1]
                                    withAnimation {
                                        scrollProxy.scrollTo(ObjectIdentifier(postListingViewModel.posts[index + 1]), anchor: .top)
                                    }
                                }
                            } else {
                                postListingViewModel.lazyModeScrolledPost = nil
                                if !postListingViewModel.appearedPosts.isEmpty {
                                    postListingViewModel.lazyModeScrolledPost = postListingViewModel.appearedPosts[postListingViewModel.appearedPosts.count - 1]
                                    for appearedPost in postListingViewModel.appearedPosts.reversed() {
                                        if let index = postListingViewModel.posts.index(id: appearedPost.id) {
                                            if index < postListingViewModel.posts.count {
                                                postListingViewModel.lazyModeScrolledPost = postListingViewModel.posts[index + 1]
                                                withAnimation {
                                                    scrollProxy.scrollTo(ObjectIdentifier(postListingViewModel.posts[index + 1]), anchor: .top)
                                                }
                                            }
                                            break
                                        }
                                    }
                                } else if !postListingViewModel.posts.isEmpty {
                                    postListingViewModel.lazyModeScrolledPost = postListingViewModel.posts[0]
                                    withAnimation {
                                        scrollProxy.scrollTo(ObjectIdentifier(postListingViewModel.posts[0]), anchor: .top)
                                    }
                                }
                            }
                        } else {
                            if !postListingViewModel.appearedPosts.isEmpty {
                                postListingViewModel.lazyModeScrolledPost = postListingViewModel.appearedPosts[postListingViewModel.appearedPosts.count - 1]
                                for appearedPost in postListingViewModel.appearedPosts.reversed() {
                                    if let index = postListingViewModel.posts.index(id: appearedPost.id) {
                                        if index < postListingViewModel.posts.count {
                                            postListingViewModel.lazyModeScrolledPost = postListingViewModel.posts[index + 1]
                                            withAnimation {
                                                scrollProxy.scrollTo(ObjectIdentifier(postListingViewModel.posts[index + 1]), anchor: .top)
                                            }
                                        }
                                        break
                                    }
                                }
                            } else if !postListingViewModel.posts.isEmpty {
                                postListingViewModel.lazyModeScrolledPost = postListingViewModel.posts[0]
                                withAnimation {
                                    scrollProxy.scrollTo(ObjectIdentifier(postListingViewModel.posts[0]), anchor: .top)
                                }
                            }
                        }
                    }
                }
            } while !Task.isCancelled
        }
    }
    
    private func stopLazyMode() {
        postListingViewModel.lazyModeScrolledPost = nil
        lazyModeState = .stopped
        lazyMode?.cancel()
        lazyMode = nil
        
        onStopLazyMode?()
    }
    
    private func pauseLazyMode(resetScrolledPost: Bool) {
        if resetScrolledPost {
            postListingViewModel.lazyModeScrolledPost = nil
        }
        lazyModeState = .paused
        lazyMode?.cancel()
        lazyMode = nil
    }
    
    private func resumeLazyMode() {
        lazyMode?.cancel()
        lazyMode = nil
        startLazyMode()
    }
    
    enum LazyModeState {
        case stopped
        case started
        case paused
    }
}
