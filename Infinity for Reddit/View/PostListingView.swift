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
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
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
    @State private var titleToBeCopied: String?
    @State private var markdownToBeCopied: String = ""
    @State private var plainTextToBeCopied: String = ""
    @State private var textToBeSelectedAndCopiedItem: TextToBeSelectedAndCopiedItem?
    @State var lazyMode: Task<Void, Error>?
    @State var lazyModeState: LazyModeState = .stopped
    
    @AppStorage(InterfacePostUserDefaultsUtils.defaultLinkPostLayoutKey, store: .interfacePost) private var defaultLinkPostLayout: Int = 0
    @AppStorage(InterfaceUserDefaultsUtils.lazyModeIntervalKey, store: .interface) private var lazyModeInterval: Double = 2.5
    @AppStorage(MiscellaneousUserDefaultsUtils.saveLastSeenPostInFrontPageKey, store: .miscellaneous) private var saveLastSeenPostInFrontPage: Bool = false
    @AppStorage(PostHistoryUserDefaultsUtils.saveReadPostsKey, store: .postHistory) private var saveReadPosts: Bool = false
    @AppStorage(PostHistoryUserDefaultsUtils.limitHistorySizeKey, store: .postHistory) private var limitHistorySize: Bool = true
    @AppStorage(PostHistoryUserDefaultsUtils.historyLimitKey, store: .postHistory) private var historyLimit: Int = 500
    @AppStorage(PostHistoryUserDefaultsUtils.markPostsAsReadAfterVotingKey, store: .postHistory) private var markPostsAsReadAfterVoting: Bool = false
    @AppStorage(PostHistoryUserDefaultsUtils.markPostsAsReadOnScrollKey, store: .postHistory) private var markPostsAsReadOnScroll: Bool = false
    @AppStorage(GesturesButtonsUserDefaultsUtils.postLeftSwipeActionKey, store: .gesturesButtons) private var postLeftSwipeAction: Int = SwipeAction.upvote.rawValue
    @AppStorage(GesturesButtonsUserDefaultsUtils.postRightSwipeActionKey, store: .gesturesButtons) private var postRightSwipeAction: Int = SwipeAction.downvote.rawValue
    
    private let postListingMetadata: PostListingMetadata
    private var isSubredditPostListing: Bool = false
    private let handleToolbarMenu: Bool
    private let showFilterPostsOption: Bool
    private var isRootView: Bool = true
    private var pauseLazyModeExternalFlag: Bool = false
    private var onStartLazyMode: (() -> Void)?
    private var onStopLazyMode: (() -> Void)?
    private var onScroll: (() -> Void)?
    private let isPresented: Bool
    
    init(postListingMetadata: PostListingMetadata,
         externalPostFilter: PostFilter? = nil,
         handleToolbarMenu: Bool = true,
         showFilterPostsOption: Bool = true,
         isPresented: Bool = true
    ) {
        self.postListingMetadata = postListingMetadata
        if case .subreddit = postListingMetadata.postListingType {
            isSubredditPostListing = true
        }
        self.handleToolbarMenu = handleToolbarMenu
        self.showFilterPostsOption = showFilterPostsOption
        self.isPresented = isPresented
        
        _postListingViewModel = StateObject(
            wrappedValue: PostListingViewModel(
                postListingMetadata: postListingMetadata,
                externalPostFilter: externalPostFilter,
                postListingRepository: PostListingRepository(),
                historyPostsRepository: HistoryPostsRepository(),
                thingModerationRepository: ThingModerationRepository(),
                postRepository: PostRepository()
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
         onScroll: (() -> Void)? = nil,
         isPresented: Bool = true
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
        self.isPresented = isPresented
        
        _postListingViewModel = StateObject(
            wrappedValue: PostListingViewModel(
                postListingMetadata: postListingMetadata,
                externalPostFilter: externalPostFilter,
                postListingRepository: PostListingRepository(),
                historyPostsRepository: HistoryPostsRepository(),
                thingModerationRepository: ThingModerationRepository(),
                postRepository: PostRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            if postListingViewModel.posts.isEmpty {
                ZStack {
                    if postListingViewModel.isInitialLoading {
                        ProgressIndicator()
                    } else if postListingViewModel.isInitialLoad, let error = postListingViewModel.postLoadingError {
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
                                postLayout: getPostLayout(post),
                                iconType: iconType,
                                onUpvote: {
                                    await postListingViewModel.votePost(
                                        post: post,
                                        vote: 1,
                                        saveReadPosts: saveReadPosts,
                                        limitHistorySize: limitHistorySize,
                                        historyLimit: historyLimit,
                                        markPostsAsReadAfterVoting: markPostsAsReadAfterVoting
                                    )
                                },
                                onDownvote: {
                                    await postListingViewModel.votePost(
                                        post: post,
                                        vote: -1,
                                        saveReadPosts: saveReadPosts,
                                        limitHistorySize: limitHistorySize,
                                        historyLimit: historyLimit,
                                        markPostsAsReadAfterVoting: markPostsAsReadAfterVoting
                                    )
                                },
                                onToggleSave: {
                                    await postListingViewModel.savePost(post: post, save: !post.saved)
                                },
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
                                },
                                onReadPost: {
                                    await postListingViewModel.readPost(post: post, saveReadPosts: saveReadPosts, limitHistorySize: limitHistorySize, historyLimit: historyLimit)
                                }
                            )
                            .limitedWidth()
                            .id(ObjectIdentifier(post))
                            .listPlainItemNoInsets()
                            .onAppear {
                                postListingViewModel.insertIntoAppearedPosts(post, saveLastSeenPostInFrontPage: saveLastSeenPostInFrontPage)
                                
                                if iconType == .user && post.userIconUrlString == nil {
                                    postListingViewModel.loadIcon(
                                        post: post
                                    )
                                }
                            }
                            .onDisappear {
                                postListingViewModel.appearedPosts.remove(id: post.id)
                                if !post.isRead && saveReadPosts && markPostsAsReadOnScroll {
                                    Task {
                                        await postListingViewModel.readPost(
                                            post: post,
                                            saveReadPosts: saveReadPosts,
                                            limitHistorySize: limitHistorySize,
                                            historyLimit: historyLimit
                                        )
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if let action = SwipeAction(rawValue: postLeftSwipeAction), action != .none {
                                    Button {
                                        onSwipe(action, post: post)
                                    } label: {
                                        SwiftUI.Image(systemName: action.icon)
                                            .foregroundStyle(.white)
                                    }
                                    .tint(action.getTint(customThemeViewModel: customThemeViewModel))
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                if let action = SwipeAction(rawValue: postRightSwipeAction), action != .none {
                                    Button {
                                        onSwipe(action, post: post)
                                    } label: {
                                        SwiftUI.Image(systemName: action.icon)
                                            .foregroundStyle(.white)
                                    }
                                    .tint(action.getTint(customThemeViewModel: customThemeViewModel))
                                }
                            }
                        }
                        
                        if postListingViewModel.hasMorePages {
                            if postListingViewModel.postLoadingError != nil {
                                HStack(spacing: 16) {
                                    SwiftUI.Image(systemName: "exclamationmark.circle")
                                        .primaryIcon()
                                    
                                    Text("Error loading more posts. Tap to retry.")
                                        .primaryText()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .contentShape(Rectangle())
                                .listPlainItemNoInsets()
                                .onTapGesture {
                                    postListingViewModel.postLoadingError = nil
                                }
                            } else {
                                HStack {
                                    ProgressIndicator()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .listPlainItemNoInsets()
                                .task {
                                    await postListingViewModel.loadPosts()
                                }
                            }
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
                    .onScrollPhaseChange { _, phase in
                        switch phase {
                        case .idle:
                            if lazyModeState == .paused {
                                resumeLazyMode()
                            }
                            postListingViewModel.isScrollIdle = true
                            postListingViewModel.applyPendingUserIconUrlString()
                        case .interacting:
                            if lazyModeState == .started {
                                pauseLazyMode(resetScrolledPost: true)
                            }
                            postListingViewModel.isScrollIdle = false
                        default:
                            break
                        }
                    }
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
        .task(id: taskKey) {
            guard isPresented else {
                return
            }
            
            await postListingViewModel.initialLoadPosts(saveLastSeenPostInFrontPage: saveLastSeenPostInFrontPage)
        }
        .onAppear {
            setUpMenu()
            
            if lazyModeState == .paused {
                resumeLazyMode()
            }
        }
        .onDisappear {
            if lazyModeState == .started {
                pauseLazyMode(resetScrolledPost: false)
            }
            
            guard let navigationBarMenuKey else {
                return
            }
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
                
                if saveLastSeenPostInFrontPage {
                    postListingViewModel.saveLastSeenFrontPagePost()
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
        .onChange(of: isPresented) { _, newValue in
            setUpMenu()
            
            if newValue {
                if lazyModeState == .paused {
                    resumeLazyMode()
                }
            } else {
                if lazyModeState == .started {
                    pauseLazyMode(resetScrolledPost: false)
                }
            }
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
                },
                onCopyEntireMarkdown: {
                    snackbarManager.showSnackbar(.info("Copied"))
                },
                onCopyMarkdown: {
                    textToBeSelectedAndCopiedItem = TextToBeSelectedAndCopiedItem(content: markdownToBeCopied)
                },
                onCopyPlainText: {
                    textToBeSelectedAndCopiedItem = TextToBeSelectedAndCopiedItem(content: plainTextToBeCopied)
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
    
    private var taskKey: LoadPostsTaskKey {
        LoadPostsTaskKey(
            loadPostsTaskId: postListingViewModel.loadPostsTaskId,
            isPresented: isPresented
        )
    }
    
    private var iconType: IconType {
        return (!isSubredditPostListing || (isSubredditPostListing && postListingMetadata.postListingType.isPopularOrAll)) ? .subreddit : .user
    }
    
    private func getPostLayout(_ post: Post) -> PostLayout {
        if post.postType.isLink {
            switch defaultLinkPostLayout {
            case 0:
                return postListingViewModel.postLayout
            case 1:
                return .card
            case 2:
                return .compact
            default:
                return .card
            }
        } else {
            return postListingViewModel.postLayout
        }
    }
    
    private func setUpMenu() {
        if isPresented {
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
        } else {
            guard let navigationBarMenuKey else {
                return
            }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
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
    
    private func onSwipe(_ action: SwipeAction, post: Post) {
        switch action {
        case .none:
            break
        case .upvote:
            Task {
                await postListingViewModel.votePost(
                    post: post,
                    vote: 1,
                    saveReadPosts: saveReadPosts,
                    limitHistorySize: limitHistorySize,
                    historyLimit: historyLimit,
                    markPostsAsReadAfterVoting: markPostsAsReadAfterVoting
                )
            }
            break
        case .downvote:
            Task {
                await postListingViewModel.votePost(
                    post: post,
                    vote: -1,
                    saveReadPosts: saveReadPosts,
                    limitHistorySize: limitHistorySize,
                    historyLimit: historyLimit,
                    markPostsAsReadAfterVoting: markPostsAsReadAfterVoting
                )
            }
            break
        }
    }
    
    struct LoadPostsTaskKey: Hashable {
        let loadPostsTaskId: UUID
        let isPresented: Bool
    }
}
