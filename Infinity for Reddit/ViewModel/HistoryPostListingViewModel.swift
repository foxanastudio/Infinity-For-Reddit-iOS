//
//  HistoryPostListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-03.
//

import Foundation
import Combine
import MarkdownUI
import GRDB
import SwiftUI
import IdentifiedCollections

public class HistoryPostListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var posts: IdentifiedArrayOf<Post> = []
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    @Published var error: Error?
    @Published var loadPostsTaskId = UUID()
    @Published var postLayout: PostLayout
    @Published var showMediaDownloadFinishedMessageTrigger: Bool = false
    @Published var showAllGalleryMediaDownloadFinishedMessageTrigger: Bool = false
    
    var appearedPosts: IdentifiedArrayOf<Post> = []
    var lazyModeScrolledPost: Post?
    var isScrollIdle: Bool = true
    
    private var historyPostListingMetadata: HistoryPostListingMetadata
    private var externalPostFilter: PostFilter?
    private var postFilter: PostFilter?
    private var before: Int64? = nil
    
    // UserDefaults
    private var spoilerContent: Bool
    
    private let historyPostListingRepository: HistoryPostListingRepositoryProtocol
    private let historyPostsRepository: HistoryPostsRepositoryProtocol
    private let thingModerationRepository: ThingModerationRepositoryProtocol
    private let postRepository: PostRepositoryProtocol
    private var resolvedIconStringUrlCache: [String: String] = [:]
    
    private var refreshPostsContinuation: CheckedContinuation<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(
        historyPostListingMetadata: HistoryPostListingMetadata,
        externalPostFilter: PostFilter?,
        historyPostListingRepository: HistoryPostListingRepositoryProtocol,
        historyPostsRepository: HistoryPostsRepositoryProtocol,
        thingModerationRepository: ThingModerationRepositoryProtocol,
        postRepository: PostRepositoryProtocol,
        postFeedID: String
    ) {
        self.historyPostListingMetadata = historyPostListingMetadata
        self.externalPostFilter = externalPostFilter
        self.historyPostListingRepository = historyPostListingRepository
        self.historyPostsRepository = historyPostsRepository
        self.thingModerationRepository = thingModerationRepository
        self.postRepository = postRepository

        self.spoilerContent = ContentSensitivityFilterUserDetailsUtils.spoilerContent
        self.postLayout = PostLayoutUserDefaultsUtils.history
        
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                let spoilerContent = UserDefaults.contentSensitivityFilter.bool(forKey: ContentSensitivityFilterUserDetailsUtils.spoilerContentKey)
                self?.setSpoilerContent(spoilerContent)
                
                let postLayout = historyPostListingMetadata.historyPostListingType.savedPostLayout
                Task { @MainActor in
                    if self?.postLayout != postLayout {
                        self?.postLayout = postLayout
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
    
    public func initialLoadPosts() async {
        guard isInitialLoad else {
            return
        }
        
        await loadPosts(isRefreshWithContinuation: refreshPostsContinuation != nil)
    }
    
    /// Fetches the next page of posts
    public func loadPosts(isRefreshWithContinuation: Bool = false) async {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else { return }
        
        let isInitialLoadCopy = isInitialLoad
        
        await MainActor.run {
            if posts.isEmpty {
                isInitialLoading = true
            } else {
                isLoadingMore = true
            }
            
            if isInitialLoad {
                isInitialLoad = false
            }
        }
        
        do {
            try Task.checkCancellation()
            
            let result = try await historyPostListingRepository.fetchPosts(
                historyPostListingType: historyPostListingMetadata.historyPostListingType,
                username: AccountViewModel.shared.account.username,
                before: before
            )
            
            guard let result else {
                await MainActor.run {
                    hasMorePages = false
                    self.before = nil
                    
                    if isRefreshWithContinuation {
                        finishPullToRefresh()
                    }
                    
                    isInitialLoading = false
                    isLoadingMore = false
                }
                return
            }
            
            let postListing = result.postListing
            
            if postListing.posts.isEmpty {
                // No more posts
                await MainActor.run {
                    hasMorePages = false
                    self.before = nil
                }
            } else {
                try Task.checkCancellation()
                
                if postFilter == nil {
                    await fetchPostFilter()
                }
                
                let processedPosts = await self.postProcessPosts(postListing.posts)
                
                try Task.checkCancellation()
                
                self.before = result.before
                
                await MainActor.run {
                    if isRefreshWithContinuation {
                        self.posts.removeAll()
                    }
                    self.posts.append(contentsOf: processedPosts)
                    hasMorePages = true
                }
            }
            
            await MainActor.run {
                if isRefreshWithContinuation {
                    finishPullToRefresh()
                }
                
                isInitialLoading = false
                isLoadingMore = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                
                isInitialLoad = isInitialLoadCopy
                isInitialLoading = false
                isLoadingMore = false
            }
            
            printInDebugOnly("Error fetching posts: \(error)")
        }
    }
    
    @MainActor
    func refreshPostsWithContinuation() async {
        resetPostLoadingState()
        await withCheckedContinuation { continuation in
            refreshPostsContinuation = continuation
            loadPostsTaskId = UUID()
        }
    }
    
    func refreshPosts() {
        resetPostLoadingState()
        loadPostsTaskId = UUID()
    }
    
    private func resetPostLoadingState() {
        isInitialLoad = true
        isInitialLoading = false
        isLoadingMore = false
        
        before = nil
        hasMorePages = true
        if refreshPostsContinuation == nil {
            posts.removeAll()
        }
    }
    
    func finishPullToRefresh() {
        refreshPostsContinuation?.resume()
        refreshPostsContinuation = nil
    }
    
    func postProcessPosts(_ posts: [Post]) async -> [Post] {
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
        
        return posts.filter { post in
            return PostFilter.isPostAllowed(post: post, postFilter: postFilter)
            && !(AccountViewModel.shared.account.isAnonymous() && hiddenPostIdsAnonymous.contains(post.id) && historyPostListingMetadata.historyPostListingType != .hidden)
        }.map {
            if !$0.selftext.isEmpty {
                modifyPostBody($0)
                $0.selftextProcessedMarkdown = MarkdownContent($0.selftext)
            }
            
            if AccountViewModel.shared.account.isAnonymous() {
                if upvotedPostIdsAnonymous.contains($0.id) {
                    $0.likes = 1
                } else if downvotedPostIdsAnonymous.contains($0.id) {
                    $0.likes = -1
                }
                $0.hidden = hiddenPostIdsAnonymous.contains($0.id)
                $0.saved = savedPostIdsAnonymous.contains($0.id)
            }
            
            return $0
        }
    }
    
    func modifyPostBody(_ post: Post) {
        MarkdownUtils.parseRedditImagesBlock(post)
    }
    
    func fetchPostFilter() async {
        self.postFilter = await historyPostListingRepository.getPostFilter(
            historyPostListingType: historyPostListingMetadata.historyPostListingType,
            externalPostFilter: externalPostFilter
        )
        self.postFilter?.allowSensitive = AccountViewModel.shared.account.allowSensitive
        self.postFilter?.allowSpoiler = spoilerContent
    }
    
    func loadIcon(post: Post) async {
        guard post.resolvedSubredditIconUrlString == nil else { return }
        
        do {
            let resolvedIconUrlString = try await historyPostListingRepository.loadIcon(post: post)
            await MainActor.run {
                if isScrollIdle {
                    post.resolvedSubredditIconUrlString = resolvedIconUrlString
                } else {
                    resolvedIconStringUrlCache[post.id] = resolvedIconUrlString
                }
            }
        } catch {
            printInDebugOnly("Load icon failed")
        }
    }
    
    func applyPendingResolvedIconUrlString() {
        for (postId, resolvedIconUrlString) in resolvedIconStringUrlCache {
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].resolvedSubredditIconUrlString = resolvedIconUrlString
            }
        }
        resolvedIconStringUrlCache.removeAll()
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
        historyPostListingMetadata.historyPostListingType.savePostLayout(postLayout: newLayout)
        postLayout = newLayout
    }
    
    func insertIntoAppearedPosts(_ post: Post) {
        if appearedPosts.index(id: post.id) != nil {
            return
        }
        
        appearedPosts.append(post)
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
                try await historyPostListingRepository.toggleHidePost(post)
                
                post.hidden = !previousHiddenState
            } catch {
                post.hidden = previousHiddenState
                self.error = error
                printInDebugOnly(error)
            }
        }
    }
    
    @MainActor
    private func toggleHidePostAnonymous(_ post: Post) {
        Task {
            try? await historyPostListingRepository.toggleHidePostAnonymous(post)
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
                printInDebugOnly(error)
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
                printInDebugOnly(error)
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
                printInDebugOnly(error)
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
                printInDebugOnly(error)
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
                printInDebugOnly(error)
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
                printInDebugOnly(error)
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
                printInDebugOnly(error)
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
                    printInDebugOnly(error.localizedDescription)
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
    
    @MainActor
    func votePost(post: Post, vote: Int) async {
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
    func readPost(post: Post, markPostsAsRead: Bool, limitHistorySize: Bool, historyLimit: Int) async {
        guard !post.isRead, markPostsAsRead else {
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
