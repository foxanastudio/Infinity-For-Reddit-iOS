//
//  HistoryPostListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-03.
//

import SwiftUI
import GRDB
import Alamofire

struct HistoryPostListingView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @StateObject var historyPostListingViewModel: HistoryPostListingViewModel
    @StateObject var postListingVideoManager: PostListingVideoManager = .init()
    
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var navigationBarMenuKey: UUID?
    @State private var showLayoutTypeSheet: Bool = false
    @State private var showPostOptionsSheet: Bool = false
    @State private var showPostShareSheet: Bool = false
    @State private var showPostModerationSheet: Bool = false
    @State private var showCopyContentOptionsSheet: Bool = false
    @State private var titleToBeCopied: String?
    @State private var markdownToBeCopied: String = ""
    @State private var plainTextToBeCopied: String = ""
    @State private var textToBeSelectedAndCopiedItem: TextToBeSelectedAndCopiedItem?
    @State private var postForPostOptionsSheet: Post?
    @State var lazyMode: Task<Void, Error>?
    @State var lazyModeState: LazyModeState = .stopped
    
    @AppStorage(InterfacePostUserDefaultsUtils.defaultLinkPostLayoutKey, store: .interfacePost) private var defaultLinkPostLayout: Int = 0
    @AppStorage(InterfaceUserDefaultsUtils.lazyModeIntervalKey, store: .interface) private var lazyModeInterval: Double = 2.5
    @AppStorage(PostHistoryUserDefaultsUtils.markPostsAsReadKey, store: .postHistory) private var markPostsAsRead: Bool = false
    @AppStorage(PostHistoryUserDefaultsUtils.limitReadPostsKey, store: .postHistory) private var limitReadPosts: Bool = true
    @AppStorage(PostHistoryUserDefaultsUtils.readPostsLimitKey, store: .postHistory) private var readPostsLimit: Int = 500

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
                thingModerationRepository: ThingModerationRepository(),
                postRepository: PostRepository(),
                postFeedID: "read_posts"
            )
        )
    }
    
    var body: some View {
        RootView {
            if historyPostListingViewModel.posts.isEmpty {
                ZStack {
                    if historyPostListingViewModel.isInitialLoading {
                        ProgressIndicator()
                    } else if historyPostListingViewModel.isInitialLoad, let error = historyPostListingViewModel.error {
                        Text("Unable to load posts. Tap to retry. Error: \(error.localizedDescription)")
                            .primaryText()
                            .padding(16)
                            .onTapGesture {
                                historyPostListingViewModel.refreshPosts()
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
                        ForEach(historyPostListingViewModel.posts, id: \.id) { post in
                            PostView(
                                post: post,
                                postLayout: getPostLayout(post),
                                isSubredditPostListing: false,
                                onUpvote: {
                                    await historyPostListingViewModel.votePost(post: post, vote: 1)
                                },
                                onDownvote: {
                                    await historyPostListingViewModel.votePost(post: post, vote: -1)
                                },
                                onToggleSave: {
                                    await historyPostListingViewModel.savePost(post: post, save: !post.saved)
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
                                    await historyPostListingViewModel.readPost(post: post, markPostsAsRead: markPostsAsRead, limitReadPosts: limitReadPosts, readPostsLimit: readPostsLimit)
                                }
                            )
                            .id(ObjectIdentifier(post))
                            .listPlainItemNoInsets()
                            .onAppear {
                                historyPostListingViewModel.insertIntoAppearedPosts(post)
                                
                                if post.subredditOrUserIcon == nil {
                                    Task {
                                        await historyPostListingViewModel.loadIcon(post: post)
                                    }
                                }
                            }
                            .onDisappear {
                                historyPostListingViewModel.appearedPosts.remove(id: post.id)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    Task {
                                        await historyPostListingViewModel.votePost(post: post, vote: 1)
                                    }
                                } label: {
                                    SwiftUI.Image(systemName: "arrowshape.up")
                                        .foregroundStyle(.white)
                                }
                                .tint(Color(hex: customThemeViewModel.currentCustomTheme.upvoted))
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    Task {
                                        await historyPostListingViewModel.votePost(post: post, vote: -1)
                                    }
                                } label: {
                                    SwiftUI.Image(systemName: "arrowshape.down")
                                        .foregroundStyle(.white)
                                }
                                .tint(Color(hex: customThemeViewModel.currentCustomTheme.downvoted))
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
                    .scrollIndicators(.hidden)
                    .refreshable {
                        await historyPostListingViewModel.refreshPostsWithContinuation()
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
                .showErrorUsingSnackbar(historyPostListingViewModel.$error)
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
        .onChange(of: historyPostListingViewModel.showMediaDownloadFinishedMessageTrigger) {
            snackbarManager.showSnackbar(.info("Download complete."))
        }
        .onChange(of: historyPostListingViewModel.showAllGalleryMediaDownloadFinishedMessageTrigger) {
            snackbarManager.showSnackbar(.info("Gallery download complete."))
        }
        .wrapContentSheet(isPresented: $showLayoutTypeSheet) {
            PostLayoutSheet(
                currentPostLayout: historyPostListingViewModel.postLayout,
                onSelectPostLayout: { newLayout in
                    historyPostListingViewModel.changePostLayout(newLayout)
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
                        historyPostListingViewModel.toggleHidePost(postForPostOptionsSheet)
                    },
                    onCrosspost: {
                        navigationManager.append(AppNavigation.crosspost(postToBeCrossposted: postForPostOptionsSheet))
                    },
                    onDownloadMedia: {
                        historyPostListingViewModel.downloadMedia(postForPostOptionsSheet)
                    },
                    onDownloadAllGalleryMedia: {
                        historyPostListingViewModel.downloadAllGalleryMedia(post: postForPostOptionsSheet)
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
                        historyPostListingViewModel.approvePost(postForPostOptionsSheet)
                    },
                    onRemove: {
                        historyPostListingViewModel.removePost(postForPostOptionsSheet, isSpam: false)
                    },
                    onMarkAsSpam: {
                        historyPostListingViewModel.removePost(postForPostOptionsSheet, isSpam: true)
                    },
                    onToggleStickyPost: {
                        historyPostListingViewModel.toggleSticky(postForPostOptionsSheet)
                    },
                    onToggleLock: {
                        historyPostListingViewModel.toggleLockPost(postForPostOptionsSheet)
                    },
                    onToggleSensitive: {
                        historyPostListingViewModel.toggleSensitive(postForPostOptionsSheet)
                    },
                    onToggleSpoiler: {
                        historyPostListingViewModel.toggleSpoiler(postForPostOptionsSheet)
                    },
                    onToggleDistinguishAsModerator: {
                        historyPostListingViewModel.toggleDistinguishAsMod(postForPostOptionsSheet)
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
    
    private func getPostLayout(_ post: Post) -> PostLayout {
        if post.postType.isLink {
            switch defaultLinkPostLayout {
            case 0:
                return historyPostListingViewModel.postLayout
            case 1:
                return .card
            case 2:
                return .compact
            default:
                return .card
            }
        } else {
            return historyPostListingViewModel.postLayout
        }
    }
    
    private func setUpMenu() {
        if let key = navigationBarMenuKey {
            navigationBarMenuManager.pop(key: key)
        }
        var options = [
            NavigationBarMenuItem(title: "Refresh") {
                historyPostListingViewModel.refreshPosts()
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
            }
        ]
        
        if showFilterPostsOption {
            options.append(NavigationBarMenuItem(title: "Filter Posts") {
                navigationManager.append(
                    AppNavigation.filterHistoryPosts(
                        historyPostListingMetadata: historyPostListingMetadata
                    )
                )
            })
        }
        
        navigationBarMenuKey = navigationBarMenuManager.push(options)
    }
    
    private func onPostTypeClicked(post: Post) {
        if showFilterPostsOption {
            navigationManager.append(
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
            navigationManager.append(
                AppNavigation.filteredHistoryPosts(
                    historyPostListingMetadata: historyPostListingMetadata,
                    postFilter: postFilter
                )
            )
        }
    }
    
    private func startLazyMode() {
        guard lazyMode == nil else {
            return
        }
        
        lazyModeState = .started
        
        if historyPostListingViewModel.lazyModeScrolledPost == nil {
            if !historyPostListingViewModel.appearedPosts.isEmpty {
                historyPostListingViewModel.sortAppearedPosts()
                historyPostListingViewModel.lazyModeScrolledPost = historyPostListingViewModel.appearedPosts[0]
            } else if !historyPostListingViewModel.posts.isEmpty {
                historyPostListingViewModel.lazyModeScrolledPost = historyPostListingViewModel.posts[0]
            }
        }
        
        lazyMode = Task {
            repeat {
                try? await Task.sleep(for: .seconds(lazyModeInterval))
                await MainActor.run {
                    if Task.isCancelled {
                        return
                    }
                    
                    if let scrollProxy = scrollProxy, !historyPostListingViewModel.posts.isEmpty {
                        if let scrolledParent = historyPostListingViewModel.lazyModeScrolledPost {
                            if let index = historyPostListingViewModel.posts.index(id: scrolledParent.id) {
                                if index < historyPostListingViewModel.posts.count - 1 {
                                    historyPostListingViewModel.lazyModeScrolledPost = historyPostListingViewModel.posts[index + 1]
                                    withAnimation {
                                        scrollProxy.scrollTo(ObjectIdentifier(historyPostListingViewModel.posts[index + 1]), anchor: .top)
                                    }
                                }
                            } else {
                                historyPostListingViewModel.lazyModeScrolledPost = nil
                                if !historyPostListingViewModel.appearedPosts.isEmpty {
                                    historyPostListingViewModel.sortAppearedPosts()
                                    historyPostListingViewModel.lazyModeScrolledPost = historyPostListingViewModel.appearedPosts[historyPostListingViewModel.appearedPosts.count - 1]
                                    for appearedPost in historyPostListingViewModel.appearedPosts.reversed() {
                                        if let index = historyPostListingViewModel.posts.index(id: appearedPost.id) {
                                            if index < historyPostListingViewModel.posts.count {
                                                historyPostListingViewModel.lazyModeScrolledPost = historyPostListingViewModel.posts[index + 1]
                                                withAnimation {
                                                    scrollProxy.scrollTo(ObjectIdentifier(historyPostListingViewModel.posts[index + 1]), anchor: .top)
                                                }
                                            }
                                            break
                                        }
                                    }
                                } else if !historyPostListingViewModel.posts.isEmpty {
                                    historyPostListingViewModel.lazyModeScrolledPost = historyPostListingViewModel.posts[0]
                                    withAnimation {
                                        scrollProxy.scrollTo(ObjectIdentifier(historyPostListingViewModel.posts[0]), anchor: .top)
                                    }
                                }
                            }
                        } else {
                            if !historyPostListingViewModel.appearedPosts.isEmpty {
                                historyPostListingViewModel.sortAppearedPosts()
                                historyPostListingViewModel.lazyModeScrolledPost = historyPostListingViewModel.appearedPosts[historyPostListingViewModel.appearedPosts.count - 1]
                                for appearedPost in historyPostListingViewModel.appearedPosts.reversed() {
                                    if let index = historyPostListingViewModel.posts.index(id: appearedPost.id) {
                                        if index < historyPostListingViewModel.posts.count {
                                            historyPostListingViewModel.lazyModeScrolledPost = historyPostListingViewModel.posts[index + 1]
                                            withAnimation {
                                                scrollProxy.scrollTo(ObjectIdentifier(historyPostListingViewModel.posts[index + 1]), anchor: .top)
                                            }
                                        }
                                        break
                                    }
                                }
                            } else if !historyPostListingViewModel.posts.isEmpty {
                                historyPostListingViewModel.lazyModeScrolledPost = historyPostListingViewModel.posts[0]
                                withAnimation {
                                    scrollProxy.scrollTo(ObjectIdentifier(historyPostListingViewModel.posts[0]), anchor: .top)
                                }
                            }
                        }
                    }
                }
            } while !Task.isCancelled
        }
    }
    
    private func stopLazyMode() {
        historyPostListingViewModel.lazyModeScrolledPost = nil
        lazyModeState = .stopped
        lazyMode?.cancel()
        lazyMode = nil
    }
    
    private func pauseLazyMode(resetScrolledPost: Bool) {
        if resetScrolledPost {
            historyPostListingViewModel.lazyModeScrolledPost = nil
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
