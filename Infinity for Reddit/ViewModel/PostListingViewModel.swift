//
//  PostListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-05.
//

import Foundation
import Combine
import MarkdownUI
import GRDB
import SwiftUI
import IdentifiedCollections

enum PostListItem: Identifiable {
    var id: String {
        switch self {
        case .post(let post):
            return post.id
        case .loading:
            return UUID().uuidString
        }
    }
    
    case post(Post)
    case loading
}

public class PostListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var posts: IdentifiedArrayOf<Post> = []
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    @Published var error: Error?
    @Published var postLoadingError: Error?
    @Published var sortType: SortType
    @Published var loadPostsTaskId = UUID()
    @Published var postLayout: PostLayout
    
    var appearedPosts: IdentifiedArrayOf<Post> = []
    var lazyModeScrolledPost: Post?
    var isScrollIdle: Bool = true
    
    private var userIconStringUrlCache: [String: String] = [:]
    
    @Published var showMediaDownloadFinishedMessageTrigger: Bool = false
    @Published var showAllGalleryMediaDownloadFinishedMessageTrigger: Bool = false
    
    var itemsWithLoadingIndicator: [PostListItem] {
        if hasMorePages {
            return posts.map { .post($0) } + [.loading]
        } else {
            return posts.map { .post($0) }
        }
    }
    
    private var postListingMetadata: PostListingMetadata
    private var externalPostFilter: PostFilter?
    private var postFilter: PostFilter?
    private var lastLoadedSortType: SortType? = nil
    private var allPostIds = Set<String>()
    private var after: String? = nil
    private var lastSeenFrontPagePost: Post? = nil
    
    // UserDefaults
    private var spoilerContent: Bool
    
    private let postListingRepository: PostListingRepositoryProtocol
    private let historyPostsRepository: HistoryPostsRepositoryProtocol
    private let thingModerationRepository: ThingModerationRepositoryProtocol
    private let postRepository: PostRepositoryProtocol
    
    private var refreshPostsContinuation: CheckedContinuation<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(
        postListingMetadata: PostListingMetadata,
        externalPostFilter: PostFilter?,
        postListingRepository: PostListingRepositoryProtocol,
        historyPostsRepository: HistoryPostsRepositoryProtocol,
        thingModerationRepository: ThingModerationRepositoryProtocol,
        postRepository: PostRepositoryProtocol
    ) {
        self.sortType = postListingMetadata.postListingType.savedSortType
        self.postListingMetadata = postListingMetadata
        self.externalPostFilter = externalPostFilter
        self.postListingRepository = postListingRepository
        self.historyPostsRepository = historyPostsRepository
        self.thingModerationRepository = thingModerationRepository
        self.postRepository = postRepository
        
        self.spoilerContent = ContentSensitivityFilterUserDetailsUtils.spoilerContent
        self.postLayout = postListingMetadata.postListingType.savedPostLayout
        
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                self.setSpoilerContent(UserDefaults.contentSensitivityFilter.bool(forKey: ContentSensitivityFilterUserDetailsUtils.spoilerContentKey))
                
                let postLayout = postListingMetadata.postListingType.savedPostLayout
                Task { @MainActor in
                    if self.postLayout != postLayout {
                        self.postLayout = postLayout
                    }
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: Notification.Name.accountAllowSensitiveChanged)
            .sink { [weak self] notification in
                self?.sensitiveContentChanged(AccountAllowSensitiveNotification.isAllowSensitive(notification))
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    
    public func initialLoadPosts(saveLastSeenPostInFrontPage: Bool) async {
        if sortType != lastLoadedSortType {
            await resetPostLoadingState()
        }
        
        guard isInitialLoad else {
            return
        }
        
        if saveLastSeenPostInFrontPage && postListingMetadata.postListingType.isFrontPage {
            self.after = MiscellaneousUserDefaultsUtils.getLastSeenPostInFrontPage(account: AccountViewModel.shared.account)
        }
        
        await loadPosts(isRefreshWithContinuation: refreshPostsContinuation != nil)
    }
    
    /// Fetches the next page of posts
    public func loadPosts(isRefreshWithContinuation: Bool = false) async {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else { return }
        
        let isInitailLoadCopy = isInitialLoad
        
        await MainActor.run {
            if posts.isEmpty {
                isInitialLoading = true
            } else {
                isLoadingMore = true
            }
            
            if isInitialLoad {
                isInitialLoad = false
            }
            
            self.postLoadingError = nil
        }
        
        do {
            try Task.checkCancellation()
            
            if case .anonymousFrontPage(let concatenatedSubscriptions) = postListingMetadata.postListingType {
                if let subscriptions = concatenatedSubscriptions {
                    if !subscriptions.isEmpty {
                        postListingMetadata.pathComponents = ["subreddit": subscriptions]
                    }
                } else {
                    let fetchedSubscriptions = await postListingRepository.getAnonymousSubscriptionsConcatenated()
                    postListingMetadata.postListingType = .anonymousFrontPage(concatenatedSubscriptions: fetchedSubscriptions)
                    if !fetchedSubscriptions.isEmpty {
                        postListingMetadata.pathComponents = ["subreddit": fetchedSubscriptions]
                    }
                }
            } else if case .anonymousCustomFeed(let myCustomFeed, let concatenatedSubscriptions) = postListingMetadata.postListingType {
                if let subscriptions = concatenatedSubscriptions {
                    guard !subscriptions.isEmpty else {
                        // No subreddits, abort
                        await MainActor.run {
                            hasMorePages = false
                            self.after = nil
                            
                            if isRefreshWithContinuation {
                                finishPullToRefresh()
                            }
                            
                            isInitialLoading = false
                            isLoadingMore = false
                            
                            self.lastLoadedSortType = self.sortType
                        }
                        return
                    }
                    
                    postListingMetadata.pathComponents = ["subreddit": subscriptions]
                } else {
                    let fetchedSubscriptions = await postListingRepository.getAnonymousCustomThemeSubredditsConcatenated(myCustomFeed: myCustomFeed)
                    postListingMetadata.postListingType = .anonymousCustomFeed(myCustomFeed: myCustomFeed, concatenatedSubscriptions: fetchedSubscriptions)
                    guard !fetchedSubscriptions.isEmpty else {
                        // No subreddits, abort
                        await MainActor.run {
                            hasMorePages = false
                            self.after = nil
                            
                            if isRefreshWithContinuation {
                                finishPullToRefresh()
                            }
                            
                            isInitialLoading = false
                            isLoadingMore = false
                            
                            self.lastLoadedSortType = self.sortType
                        }
                        return
                    }
                    
                    postListingMetadata.pathComponents = ["subreddit": fetchedSubscriptions]
                }
            }
            
            let postListing: PostListing
            switch postListingMetadata.postListingType.sortEmbeddingStyle {
            case .inPath:
                var queries: [String: String]
                if let time = sortType.time?.rawValue {
                    queries = ["t": time, "limit": "100", "after": self.after ?? ""]
                } else {
                    queries = ["limit": "100", "after": self.after ?? ""]
                }
                if postListingMetadata.postListingType.canQuerySensitiveInAPICall {
                    queries["include_over_18"] = AccountViewModel.shared.account.allowSensitive ? "1" : "0"
                }
                postListing = try await postListingRepository.fetchPosts(
                    postListingType: postListingMetadata.postListingType,
                    pathComponents: ["sortType": sortType.type.rawValue].merging(postListingMetadata.pathComponents, uniquingKeysWith: { _, new in new }),
                    queries: queries.merging(postListingMetadata.queries ?? [:], uniquingKeysWith: { _, new in new }),
                    params: postListingMetadata.params
                )
            case .inQuery(let key):
                var queries: [String: String]
                if let time = sortType.time?.rawValue {
                    queries = [key: sortType.type.rawValue, "t": time, "limit": "100", "after": self.after ?? ""]
                } else {
                    queries = [key: sortType.type.rawValue, "limit": "100", "after": self.after ?? ""]
                }
                if postListingMetadata.postListingType.canQuerySensitiveInAPICall {
                    queries["include_over_18"] = AccountViewModel.shared.account.allowSensitive ? "1" : "0"
                }
                postListing = try await postListingRepository.fetchPosts(
                    postListingType: postListingMetadata.postListingType,
                    pathComponents: postListingMetadata.pathComponents,
                    queries: queries.merging(postListingMetadata.queries ?? [:], uniquingKeysWith: { _, new in new }),
                    params: postListingMetadata.params
                )
            case .none:
                var queries = ["limit": "100", "after": self.after ?? ""]
                if postListingMetadata.postListingType.canQuerySensitiveInAPICall {
                    queries["include_over_18"] = AccountViewModel.shared.account.allowSensitive ? "1" : "0"
                }
                postListing = try await postListingRepository.fetchPosts(
                    postListingType: postListingMetadata.postListingType,
                    pathComponents: postListingMetadata.pathComponents,
                    queries: queries.merging(postListingMetadata.queries ?? [:], uniquingKeysWith: { _, new in new }),
                    params: postListingMetadata.params
                )
            }
            
            try Task.checkCancellation()
            
            if postFilter == nil {
                await fetchPostFilter()
            }
            
            let processedPosts = await self.postProcessPosts(postListing.posts)
            
            try Task.checkCancellation()
            
            if (processedPosts.isEmpty) {
                // No more posts
                await MainActor.run {
                    hasMorePages = false
                    self.after = nil
                }
            } else {
                let realNewPosts = processedPosts.filter {
                    !self.allPostIds.contains($0.id)
                }
                
                self.after = postListing.after
                
                allPostIds.formUnion(
                    realNewPosts
                        .compactMap {
                            $0.id
                        }
                )
                
                await MainActor.run {
                    if isRefreshWithContinuation {
                        self.posts.removeAll()
                        self.appearedPosts.removeAll()
                        self.lazyModeScrolledPost = nil
                    }
                    self.posts.append(contentsOf: realNewPosts)
                    hasMorePages = !(self.after == nil || self.after?.isEmpty == true)
                }
            }
            
            await MainActor.run {
                if isRefreshWithContinuation {
                    finishPullToRefresh()
                }
                
                isInitialLoading = false
                isLoadingMore = false
                
                self.lastLoadedSortType = self.sortType
            }
        } catch {
            await MainActor.run {
                self.postLoadingError = error
                
                isInitialLoad = isInitailLoadCopy
                isInitialLoading = false
                isLoadingMore = false
            }
        }
    }
    
    @MainActor
    func refreshPostsWithContinuation() async {
        await withCheckedContinuation { continuation in
            refreshPostsContinuation = continuation
            lastLoadedSortType = nil
            loadPostsTaskId = UUID()
        }
    }
    
    func refreshPosts() {
        lastLoadedSortType = nil
        loadPostsTaskId = UUID()
    }
    
    private func resetPostLoadingState() async {
        await MainActor.run {
            isInitialLoad = true
            isInitialLoading = false
            isLoadingMore = false
            
            after = nil
            hasMorePages = true
            if refreshPostsContinuation == nil {
                posts.removeAll()
                appearedPosts.removeAll()
                lazyModeScrolledPost = nil
            }
            
            allPostIds = Set<String>()
        }
    }
    
    func finishPullToRefresh() {
        refreshPostsContinuation?.resume()
        refreshPostsContinuation = nil
    }
    
    func postProcessPosts(_ posts: [Post]) async -> [Post] {
        let readPostIds = await historyPostsRepository.getReadPostsIdsByIds(
            saveReadPosts: PostHistoryUserDefaultsUtils.saveReadPosts,
            account: AccountViewModel.shared.account,
            postIds: posts.map { $0.id }
        )
        let upvotedPostIdsAnonymous = AccountViewModel.shared.account.isAnonymous() ? await historyPostsRepository.getHistoryPostsIdsByIdsAnonymous(
            postIds: posts.map { $0.id },
            postHistoryType: .upvoted
        ) : Set<String>()
        let downvotedPostIdsAnonymous = AccountViewModel.shared.account.isAnonymous() ? await historyPostsRepository.getHistoryPostsIdsByIdsAnonymous(
            postIds: posts.map { $0.id },
            postHistoryType: .downvoted
        ) : Set<String>()
        let hiddenPostIdsAnonymous = AccountViewModel.shared.account.isAnonymous() ? await historyPostsRepository.getHistoryPostsIdsByIdsAnonymous(
            postIds: posts.map { $0.id },
            postHistoryType: .hidden
        ) : Set<String>()
        let savedPostIdsAnonymous = AccountViewModel.shared.account.isAnonymous() ? await historyPostsRepository.getHistoryPostsIdsByIdsAnonymous(
            postIds: posts.map { $0.id },
            postHistoryType: .saved
        ) : Set<String>()
        
        let hideReadPosts = postListingMetadata.postListingType.hideReadPostsAutomatically
        
        return posts.filter { post in
            return PostFilter.isPostAllowed(post: post, postFilter: postFilter)
            && !(AccountViewModel.shared.account.isAnonymous() && hiddenPostIdsAnonymous.contains(post.id))
            && !(hideReadPosts && readPostIds.contains(post.id))
        }.map {
            if !$0.selftext.isEmpty {
                modifyPostBody($0)
                $0.selftextProcessedMarkdown = MarkdownContent($0.selftext)
            }
            
            if readPostIds.contains($0.id) {
                $0.isRead = true
            }
            if AccountViewModel.shared.account.isAnonymous() {
                if upvotedPostIdsAnonymous.contains($0.id) {
                    $0.likes = 1
                } else if downvotedPostIdsAnonymous.contains($0.id) {
                    $0.likes = -1
                }
                $0.saved = savedPostIdsAnonymous.contains($0.id)
            }
            
            return $0
        }
    }
    
    func modifyPostBody(_ post: Post) {
        MarkdownUtils.parseRedditImagesBlock(post)
    }
    
    func fetchPostFilter() async {
        self.postFilter = await postListingRepository.getPostFilter(
            postListingType: postListingMetadata.postListingType,
            externalPostFilter: externalPostFilter
        )
        self.postFilter?.allowSensitive = AccountViewModel.shared.account.allowSensitive
        self.postFilter?.allowSpoiler = spoilerContent
    }
    
    func loadIcon(post: Post) {
        guard post.userIconUrlString == nil else { return }
        
        Task {
            let startIndex = posts.index(id: post.id) ?? 0
            let postBatch = Array(
                posts[startIndex..<min(posts.count, startIndex + UserProfileImageBatchLoader.batchSize)]
            )

            let iconUrl = await UserProfileImageBatchLoader.shared.loadIcons(posts: postBatch)
            await MainActor.run {
                if isScrollIdle {
                    post.userIconUrlString = iconUrl
                } else {
                    userIconStringUrlCache[post.id] = iconUrl
                }
            }
        }
    }
    
    func applyPendingUserIconUrlString() {
        for (postId, userIconUrlString) in userIconStringUrlCache {
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].userIconUrlString = userIconUrlString
            }
        }
        userIconStringUrlCache.removeAll()
    }
    
    func changeSortTypeKind(_ sortTypeKind: SortType.Kind) {
        if sortTypeKind != self.sortType.type {
            self.sortType = SortType(type: sortTypeKind)
            loadPostsTaskId = UUID()
            if SortTypeSettingsUserDefaultsUtils.saveSortType {
                postListingMetadata.postListingType.saveSortType(sortType: self.sortType)
            }
        }
    }
    
    func changeSortType(_ sortType: SortType) {
        if sortType != self.sortType {
            self.sortType = sortType
            loadPostsTaskId = UUID()
            if SortTypeSettingsUserDefaultsUtils.saveSortType {
                postListingMetadata.postListingType.saveSortType(sortType: sortType)
            }
        }
    }
    
    func sensitiveContentChanged(_ sensitiveContent: Bool) {
        self.postFilter?.allowSensitive = sensitiveContent
        refreshPosts()
    }
    
    func setSpoilerContent(_ spoilerContent: Bool) {
        if spoilerContent != self.spoilerContent {
            self.spoilerContent = spoilerContent
            self.postFilter?.allowSpoiler = spoilerContent
            refreshPosts()
        }
    }
    
    func changePostLayout(_ newLayout: PostLayout) {
        postListingMetadata.postListingType.savePostLayout(postLayout: newLayout)
        postLayout = newLayout
    }
    
    func hideReadPosts() {
        self.posts.removeAll {
            $0.isRead
        }
        self.appearedPosts.removeAll {
            $0.isRead
        }
    }
    
    func insertIntoAppearedPosts(_ post: Post, saveLastSeenPostInFrontPage: Bool) {
        if appearedPosts.index(id: post.id) != nil {
            return
        }
        
        appearedPosts.append(post)
        
        if saveLastSeenPostInFrontPage && postListingMetadata.postListingType.isFrontPage {
            if let lastSeenPost = lastSeenFrontPagePost {
                if let index = self.posts.index(id: lastSeenPost.id) {
                    if index < self.posts.index(id: post.id) ?? 0 {
                        self.lastSeenFrontPagePost = post
                    }
                } else {
                    self.lastSeenFrontPagePost = post
                }
            } else {
                self.lastSeenFrontPagePost = post
            }
        }
    }
    
    func sortAppearedPosts() {
        appearedPosts.sort(by: { p1, p2 in
            (self.posts.index(id: p1.id) ?? posts.count) < (self.posts.index(id: p2.id) ?? posts.count)
        })
    }
    
    @MainActor
    func toggleHidePost(_ post: Post) {
        guard !AccountViewModel.shared.account.isAnonymous() else {
            toggleHidePostAnonymous(post)
            return
        }
        
        let previousHiddenState = post.hidden ?? false
        
        Task {
            do {
                try await postListingRepository.toggleHidePost(post)
                
                post.hidden = !previousHiddenState
            } catch {
                post.hidden = previousHiddenState
                self.error = error
            }
        }
    }
    
    @MainActor
    private func toggleHidePostAnonymous(_ post: Post) {
        Task {
            try? await postListingRepository.toggleHidePostAnonymous(post)
            post.hidden.toggle()
        }
    }
    
    @MainActor
    func approvePost(_ post: Post) {
        Task {
            do {
                try await thingModerationRepository.approveThing(thingFullname: post.name)
                
                post.approved = true
                post.approvedBy = AccountViewModel.shared.account.username
                post.approvedAtUtc = Utils.getCurrentTimeEpoch()
                post.removed = false
                post.removedBy = ""
                post.removedByCategory = ""
                post.spam = false
            } catch {
                self.error = error
            }
        }
    }
    
    @MainActor
    func removePost(_ post: Post, isSpam: Bool) {
        Task {
            do {
                try await thingModerationRepository.removeThing(thingFullname: post.name, isSpam: isSpam)
                
                post.approved = false
                post.approvedBy = ""
                post.approvedAtUtc = 0
                post.removed = true
                post.removedBy = AccountViewModel.shared.account.username
                post.removedByCategory = "moderator"
                post.spam = isSpam
            } catch {
                self.error = error
            }
        }
    }
    
    @MainActor
    func toggleSticky(_ post: Post) {
        Task {
            do {
                try await thingModerationRepository.toggleSticky(post: post)
                
                post.stickied.toggle()
            } catch {
                self.error = error
            }
        }
    }
    
    @MainActor
    func toggleLockPost(_ post: Post) {
        Task {
            do {
                try await thingModerationRepository.toggleLock(thingFullname: post.name, lock: !post.locked)
                
                post.locked.toggle()
            } catch {
                self.error = error
            }
        }
    }
    
    @MainActor
    func toggleSensitive(_ post: Post) {
        Task {
            do {
                try await thingModerationRepository.toggleSensitive(post: post)
                post.over18.toggle()
            } catch {
                self.error = error
            }
        }
    }
    
    @MainActor
    func toggleSpoiler(_ post: Post) {
        Task {
            do {
                try await thingModerationRepository.toggleSpoiler(post: post)
                post.spoiler.toggle()
            } catch {
                self.error = error
            }
        }
    }
    
    @MainActor
    func toggleDistinguishAsMod(_ post: Post) {
        Task {
            do {
                try await thingModerationRepository.toggleDistinguishAsMod(post: post)
                
                post.distinguished = post.distinguished == "moderator" ? "" : "moderator"
            } catch {
                self.error = error
            }
        }
    }
    
    func downloadMedia(_ post: Post) {
        guard let downloadMediaType = post.getDownloadMediaType() else {
            return
        }
        
        Task {
            do {
                try await MediaDownloader.shared.download(downloadMediaType: downloadMediaType, onProgressWithTitle: { _, progress in
                    
                })
                
                await MainActor.run {
                    self.showMediaDownloadFinishedMessageTrigger.toggle()
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
    
    func downloadAllGalleryMedia(post: Post) {
        guard let items = post.galleryData?.items else {
            return
        }
        
        Task {
            await withTaskGroup(of: Void.self) { group in
                for item in items {
                    group.addTask { [weak self] in
                        await self?.downloadGalleryOrImgurItemMediaAsync(downloadMediaType: item.toDownloadMediaType(post: post))
                    }
                }
                
                for await _ in group {
                    
                }
                
                await MainActor.run {
                    self.showAllGalleryMediaDownloadFinishedMessageTrigger.toggle()
                }
            }
        }
    }
    
    private func downloadGalleryOrImgurItemMediaAsync(downloadMediaType: DownloadMediaType) async {
        do {
            try await MediaDownloader.shared.download(downloadMediaType: downloadMediaType, onProgressWithTitle: { _, _ in })
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func saveLastSeenFrontPagePost() {
        if postListingMetadata.postListingType.isFrontPage, let lastSeenFrontPagePost {
            MiscellaneousUserDefaultsUtils.saveLastSeenPostInFrontPage(post: lastSeenFrontPagePost, account: AccountViewModel.shared.account)
        }
    }
    
    @MainActor
    func votePost(post: Post, vote: Int, saveReadPosts: Bool, limitHistorySize: Bool, historyLimit: Int, markPostsAsReadAfterVoting: Bool) async {
        if saveReadPosts && markPostsAsReadAfterVoting {
            await readPost(post: post, saveReadPosts: saveReadPosts, limitHistorySize: limitHistorySize, historyLimit: historyLimit)
        }
        
        guard !AccountViewModel.shared.account.isAnonymous() else {
            await votePostAnonymous(post: post, vote: vote)
            return
        }
        
        let previousVote = post.likes
        
        var point: String
        let finalVote: Int
        if vote == post.likes {
            point = "0"
            finalVote = 0
            post.likes = 0
        } else {
            point = String(vote)
            finalVote = vote
            post.likes = vote
        }
        self.objectWillChange.send()
        
        defer {
            self.objectWillChange.send()
        }
        
        do {
            try await postRepository.votePost(post: post, point: point)
            post.likes = finalVote
        } catch {
            post.likes = previousVote
            self.error = error
            printInDebugOnly("Error voting post: \(error)")
        }
    }
    
    @MainActor
    private func votePostAnonymous(post: Post, vote: Int) async {
        let finalVote: Int
        if vote == post.likes {
            finalVote = 0
            post.likes = 0
        } else {
            finalVote = vote
            post.likes = vote
        }
        try? await postRepository.votePostAnonymous(post: post, vote: finalVote)
    }
    
    @MainActor
    func savePost(post: Post, save: Bool) async {
        guard !AccountViewModel.shared.account.isAnonymous() else {
            await savePostAnonymous(post: post, save: save)
            return
        }
        
        let previousSaved = post.saved
        
        post.saved = save
        
        self.objectWillChange.send()
        
        defer {
            self.objectWillChange.send()
        }
        
        do {
            try await postRepository.savePost(post: post, save: save)
        } catch {
            post.saved = previousSaved
            self.error = error
            printInDebugOnly("Error (un)saving post: \(error)")
        }
    }
    
    @MainActor
    private func savePostAnonymous(post: Post, save: Bool) async {
        post.saved = save
        try? await postRepository.savePostAnonymous(post: post, save: save)
    }
    
    @MainActor
    func readPost(post: Post, saveReadPosts: Bool, limitHistorySize: Bool, historyLimit: Int) async {
        guard !post.isRead, saveReadPosts else {
            return
        }
        
        do {
            try await postRepository.readPost(
                post: post,
                account: AccountViewModel.shared.account,
                limitHistorySize: limitHistorySize,
                historyLimit: historyLimit
            )
            
            post.isRead = true
        } catch {
            printInDebugOnly("Mark post as read failed with error: \(error)")
        }
    }
}
