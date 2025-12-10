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
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @StateObject var postListingViewModel: PostListingViewModel
    @StateObject var postListingVideoManager: PostListingVideoManager = .init()
    
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var showSortTypeKindSheet: Bool = false
    @State private var showSortTypeTimeSheet: Bool = false
    @State private var upcomingSortTypeKind: SortType.Kind?
    @State private var navigationBarMenuKey: UUID?
    @State private var showLayoutTypeSheet: Bool = false
    @State private var showPostOptionsSheet: Bool = false
    @State private var showPostShareSheet: Bool = false
    @State private var showPostModerationSheet: Bool = false
    @State private var postForPostOptionsSheet: Post?
    @State private var showCopyContentOptionsSheet: Bool = false
    @State private var showCopyContentSheet: Bool = false
    @State private var titleToBeCopied: String?
    @State private var markdownToBeCopied: String = ""
    @State private var plainTextToBeCopied: String = ""
    @State private var textToBeSelectedAndCopiedItem: TextToBeSelectedAndCopiedItem?
    @State var lazyMode: Task<Void, Error>?
    @State var lazyModeState: LazyModeState = .stopped
    
    @AppStorage(InterfaceUserDefaultsUtils.lazyModeIntervalKey, store: .interface) private var lazyModeInterval: Double = 2.5
    @AppStorage(MiscellaneousUserDefaultsUtils.saveLastSeenPostInFrontPageKey, store: .miscellaneous) private var saveLastSeenPostInFrontPage: Bool = false
    
    private let postListingMetadata: PostListingMetadata
    private var isSubredditPostListing: Bool = false
    private let handleToolbarMenu: Bool
    private let showFilterPostsOption: Bool
    private var isRootView: Bool = true
    private var pauseLazyModeExternalFlag: Bool = false
    private var onStartLazyMode: (() -> Void)?
    private var onStopLazyMode: (() -> Void)?
    private var onScroll: (() -> Void)?
    
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
                historyPostsRepository: HistoryPostsRepository(),
                thingModerationRepository: ThingModerationRepository()
            )
        )
    }
    
    init(postListingMetadata: PostListingMetadata,
         externalPostFilter: PostFilter? = nil,
         isRootView: Bool = true,
         showFilterPostsOption: Bool = true,
         scrollProxy: ScrollViewProxy? = nil,
         pauseLazyModeExternalFlag: Bool,
         onStartLazyMode: (() -> Void)? = nil,
         onStopLazyMode: (() -> Void)? = nil,
         onScroll: (() -> Void)? = nil
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
        self.onScroll = onScroll
        
        _postListingViewModel = StateObject(
            wrappedValue: PostListingViewModel(
                postListingMetadata: postListingMetadata,
                externalPostFilter: externalPostFilter,
                postListingRepository: PostListingRepository(),
                historyPostsRepository: HistoryPostsRepository(),
                thingModerationRepository: ThingModerationRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            if postListingViewModel.posts.isEmpty {
                ZStack {
                    if postListingViewModel.isInitialLoading {
                        ProgressIndicator()
                    } else if postListingViewModel.isInitialLoad, let error = postListingViewModel.error {
                        Text("Unable to load posts. Tap to retry. Error: \(error.localizedDescription)")
                            .primaryText()
                            .padding(16)
                            .onTapGesture {
                                postListingViewModel.refreshPosts()
                            }
                    } else {
                        Text("No posts")
                            .primaryText()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
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
                                },
                                onLongPressPost: {
                                    postForPostOptionsSheet = post
                                    showPostOptionsSheet = true
                                },
                                onShare: {
                                    postForPostOptionsSheet = post
                                    showPostShareSheet = true
                                }
                            )
                            .id(ObjectIdentifier(post))
                            .listPlainItemNoInsets()
                            .onAppear {
                                postListingViewModel.insertIntoAppearedPosts(post, saveLastSeenPostInFrontPage: saveLastSeenPostInFrontPage)
                                
                                if post.subredditOrUserIcon == nil {
                                    postListingViewModel.loadIcon(
                                        post: post,
                                        displaySubredditIcon: !isSubredditPostListing || (isSubredditPostListing && postListingMetadata.postListingType.isPopularOrAll)
                                    )
                                }
                            }
                            .onDisappear {
                                postListingViewModel.appearedPosts.remove(id: post.id)
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
                    .scrollIndicators(.hidden)
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
                    .applyIf(onScroll != nil) {
                        $0.onScrollPhaseChange { oldPhase, newPhase, context in
                            if newPhase == .interacting {
                                onScroll?()
                            }
                        }
                    }
                }
                .showErrorUsingSnackbar(postListingViewModel.$error)
            }
        }
        .applyIf(handleToolbarMenu) {
            $0.toolbar {
                NavigationBarMenu()
            }
        }
        .task(id: postListingViewModel.loadPostsTaskId) {
            await postListingViewModel.initialLoadPosts(saveLastSeenPostInFrontPage: saveLastSeenPostInFrontPage)
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
            
            if saveLastSeenPostInFrontPage {
                postListingViewModel.saveLastSeenFrontPagePost()
            }
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
        .onChange(of: postListingViewModel.showMediaDownloadFinishedMessageTrigger) {
            snackbarManager.showSnackbar(.info("Download complete."))
        }
        .onChange(of: postListingViewModel.showAllGalleryMediaDownloadFinishedMessageTrigger) {
            snackbarManager.showSnackbar(.info("Gallery download complete."))
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
        .wrapContentSheet(isPresented: $showLayoutTypeSheet) {
            PostLayoutSheet(
                currentPostLayout: postListingViewModel.postLayout,
                onSelectPostLayout: { newLayout in
                    postListingViewModel.changePostLayout(newLayout)
                }
            )
        }
        .wrapContentSheet(isPresented: $showPostOptionsSheet) {
            if let postForPostOptionsSheet {
                PostOptionsSheet(
                    post: postForPostOptionsSheet,
                    onComment: {
                        navigationManager.append(AppNavigation.submitComment(commentParent: .post(parentPost: postForPostOptionsSheet)))
                    },
                    onShare: {
                        showPostShareSheet = true
                    },
                    onCopy: {
                        titleToBeCopied = postForPostOptionsSheet.title
                        markdownToBeCopied = postForPostOptionsSheet.selftext
                        plainTextToBeCopied = postForPostOptionsSheet.selftextHtml
                        showCopyContentOptionsSheet = true
                    },
                    onAddToPostFilter: {
                        navigationManager.append(SettingsViewNavigation.postFilter(postToBeAdded: postForPostOptionsSheet))
                    },
                    onToggleHidePost: {
                        postListingViewModel.toggleHidePost(postForPostOptionsSheet)
                    },
                    onCrosspost: {
                        navigationManager.append(AppNavigation.crosspost(postToBeCrossposted: postForPostOptionsSheet))
                    },
                    onDownloadMedia: {
                        postListingViewModel.downloadMedia(postForPostOptionsSheet)
                    },
                    onDownloadAllGalleryMedia: {
                        postListingViewModel.downloadAllGalleryMedia(post: postForPostOptionsSheet)
                    },
                    onReport: {
                        if AccountViewModel.shared.account.isAnonymous() {
                            navigationManager.openLink("https://www.reddit.com/report")
                        } else {
                            navigationManager.append(AppNavigation.report(subredditName: postForPostOptionsSheet.subreddit, thingFullname: postForPostOptionsSheet.name))
                        }
                    },
                    onModeration: {
                        showPostModerationSheet = true
                    }
                )
            } else {
                EmptyView()
            }
        }
        .wrapContentSheet(isPresented: $showPostModerationSheet) {
            if let postForPostOptionsSheet {
                PostModerationSheet(
                    post: postForPostOptionsSheet,
                    onApprove: {
                        postListingViewModel.approvePost(postForPostOptionsSheet)
                    },
                    onRemove: {
                        postListingViewModel.removePost(postForPostOptionsSheet, isSpam: false)
                    },
                    onMarkAsSpam: {
                        postListingViewModel.removePost(postForPostOptionsSheet, isSpam: true)
                    },
                    onToggleStickyPost: {
                        postListingViewModel.toggleSticky(postForPostOptionsSheet)
                    },
                    onToggleLock: {
                        postListingViewModel.toggleLockPost(postForPostOptionsSheet)
                    },
                    onToggleSensitive: {
                        postListingViewModel.toggleSensitive(postForPostOptionsSheet)
                    },
                    onToggleSpoiler: {
                        postListingViewModel.toggleSpoiler(postForPostOptionsSheet)
                    },
                    onToggleDistinguishAsModerator: {
                        postListingViewModel.toggleDistinguishAsMod(postForPostOptionsSheet)
                    }
                )
            } else {
                EmptyView()
            }
        }
        .wrapContentSheet(isPresented: $showPostShareSheet) {
            if let postForPostOptionsSheet {
                PostShareSheet(post: postForPostOptionsSheet)
            } else {
                EmptyView()
            }
        }
        .wrapContentSheet(isPresented: $showCopyContentOptionsSheet) {
            CopyContentOptionsSheet(
                title: titleToBeCopied,
                markdown: markdownToBeCopied,
                plainText: plainTextToBeCopied,
                onCopyEntireTitle: {
                    snackbarManager.showSnackbar(.info("Copied"))
                },
                onCopyTitle: {
                    textToBeSelectedAndCopiedItem = TextToBeSelectedAndCopiedItem(title: titleToBeCopied)
                    showCopyContentSheet = true
                },
                onCopyEntireMarkdown: {
                    snackbarManager.showSnackbar(.info("Copied"))
                },
                onCopyMarkdown: {
                    textToBeSelectedAndCopiedItem = TextToBeSelectedAndCopiedItem(content: markdownToBeCopied)
                    showCopyContentSheet = true
                },
                onCopyPlainText: {
                    textToBeSelectedAndCopiedItem = TextToBeSelectedAndCopiedItem(content: plainTextToBeCopied)
                    showCopyContentSheet = true
                }
            )
        }
        .sheet(item: $textToBeSelectedAndCopiedItem) { item in
            CopyContentSheet(
                content: item.title ?? item.content
            )
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
                    snackbarManager.showSnackbar(.info("Content will auto-scroll in \(lazyModeInterval) \(lazyModeInterval == 1 ? "second" : "seconds")."))
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
                navigationManager.append(
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
            navigationManager.append(
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
            navigationManager.append(
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
                postListingViewModel.sortAppearedPosts()
                postListingViewModel.lazyModeScrolledPost = postListingViewModel.appearedPosts[0]
            } else if !postListingViewModel.posts.isEmpty {
                postListingViewModel.lazyModeScrolledPost = postListingViewModel.posts[0]
            }
        }
        
        lazyMode = Task {
            repeat {
                try? await Task.sleep(for: .seconds(lazyModeInterval))
                await MainActor.run {
                    if Task.isCancelled {
                        return
                    }
                    
                    if let scrollProxy = scrollProxy, !postListingViewModel.posts.isEmpty {
                        if let scrolledParent = postListingViewModel.lazyModeScrolledPost {
                            if let index = postListingViewModel.posts.index(id: scrolledParent.id) {
                                if index < postListingViewModel.posts.count - 1 {
                                    postListingViewModel.lazyModeScrolledPost = postListingViewModel.posts[index + 1]
                                    withAnimation {
                                        scrollProxy.scrollTo(ObjectIdentifier(postListingViewModel.posts[index + 1]), anchor: .top)
                                    }
                                }
                            } else {
                                postListingViewModel.lazyModeScrolledPost = nil
                                if !postListingViewModel.appearedPosts.isEmpty {
                                    postListingViewModel.sortAppearedPosts()
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
                                postListingViewModel.sortAppearedPosts()
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
}
