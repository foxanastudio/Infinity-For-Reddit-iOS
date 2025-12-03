//
//  PostDetailsViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-23.
//

import Foundation
import Combine
import MarkdownUI
import IdentifiedCollections
import SwiftUI

public class PostDetailsViewModel: ObservableObject {
    // MARK: - Properties
    @Published var post: Post?
    @Published var visibleComments: IdentifiedArrayOf<CommentItem> = []
    var allComments: IdentifiedArrayOf<CommentItem> = []
    @Published var appearedComments: [CommentItem] = []
    @Published var isSingleThread: Bool =  false
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMoreComments: Bool = true
    @Published var error: Error?
    @Published var sortTypeKind: SortType.Kind
    @Published var loadPostAndCommentsTaskId = UUID()
    @Published var postDetailsInput: PostDetailsInput
    @Published var singleThreadContext: Int = 8
    @Published var flairs: [Flair]?
    @Published var searchQuery: String = ""
    @Published var searchedComment: CommentItem?
    
    @Published var showMediaDownloadFinishedMessageTrigger: Bool = false
    @Published var showAllGalleryMediaDownloadFinishedMessageTrigger: Bool = false
    
    private let account: Account
    private var commentMore: CommentMore?
    private var lastLoadedSortTypeKind: SortType.Kind? = nil
    private var commentFilter: CommentFilter?
    private var hasUsedRecommendedSort: Bool = false
    
    //User defaults
    private var showTopLevelCommentsFirst: Bool
    
    private let postDetailsRepository: PostDetailsRepositoryProtocol
    private let historyPostsRepository: HistoryPostsRepositoryProtocol
    private let flairRepository: FlairRepositoryProtocol
    private let thingModerationRepository: ThingModerationRepositoryProtocol
    
    private var refreshPostsContinuation: CheckedContinuation<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    private var toggleSensitiveTask: Task<Void, Never>?
    private var toggleSpoilerTask: Task<Void, Never>?
    private var selectFlairTask: Task<Void, Never>?
    
    enum PostDetailsViewModelError: LocalizedError {
        case postFetchError
        case postNotLoadedError
        
        var errorDescription: String? {
            switch self {
            case .postFetchError:
                return "Failed to fetch post."
            case .postNotLoadedError:
                return "Post not loaded."
            }
        }
    }
    
    // MARK: - Initializer
    init(
        account: Account,
        postDetailsInput: PostDetailsInput,
        postDetailsRepository: PostDetailsRepositoryProtocol,
        historyPostsRepository: HistoryPostsRepositoryProtocol,
        flairRepository: FlairRepositoryProtocol,
        thingModerationRepository: ThingModerationRepositoryProtocol,
        isContinueThread: Bool = false
    ) {
        self.account = account
        self.postDetailsInput = postDetailsInput
        self.sortTypeKind = SortTypeUserDetailsUtils.postComment
        self.postDetailsRepository = postDetailsRepository
        self.historyPostsRepository = historyPostsRepository
        self.flairRepository = flairRepository
        self.thingModerationRepository = thingModerationRepository
        self.showTopLevelCommentsFirst = InterfaceCommentUserDefaultsUtils.showTopLevelCommentsFirst
        if isContinueThread {
            self.singleThreadContext = 0
        }
        
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.showTopLevelCommentsFirst = UserDefaults.interfaceComment.bool(forKey: InterfaceCommentUserDefaultsUtils.showTopLevelCommentsFirstKey)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    
    public func initialLoadPostAndComments() async {
        if sortTypeKind != lastLoadedSortTypeKind {
            await resetPostAndCommentsLoadingState()
        }
        
        guard isInitialLoad else {
            return
        }
        
        if post == nil {
            switch postDetailsInput {
            case .post(let post):
                await MainActor.run {
                    self.post = post
                }
                await fetchPostAndComments(isRefreshWithContinuation: refreshPostsContinuation != nil)
            case .postAndCommentId:
                await fetchPostAndComments(isRefreshWithContinuation: refreshPostsContinuation != nil, shouldLoadPost: true)
            }
        } else {
            await fetchPostAndComments(isRefreshWithContinuation: refreshPostsContinuation != nil)
        }
    }
    
    public func fetchPostAndComments(isRefreshWithContinuation: Bool = false, shouldLoadPost: Bool = false, forceLoad: Bool = false) async {
        if !forceLoad {
            guard !isInitialLoading, !isLoadingMore else { return }
        }
        
        let isInitailLoadCopy = isInitialLoad
        
        await MainActor.run {
            if allComments.isEmpty {
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
            
            let postDetails: PostDetailsRootClass
            switch postDetailsInput {
            case .post(let post):
                if !hasUsedRecommendedSort && SortTypeSettingsUserDefaultsUtils.respectSubredditRecommendedCommentSortType {
                    await MainActor.run {
                        self.sortTypeKind = SortType.Kind(rawValue: post.suggestedSort) ?? self.sortTypeKind
                        self.hasUsedRecommendedSort = true
                    }
                }
                postDetails = try await postDetailsRepository.fetchComments(
                    postId: post.id,
                    queries: ["sort": sortTypeKind.rawValue]
                )
            case .postAndCommentId(let postId, let commentId):
                if let commentId = commentId {
                    postDetails = try await postDetailsRepository.fetchCommentsSingleThread(
                        postId: postId,
                        commentId: commentId,
                        queries: ["sort": sortTypeKind.rawValue, "context": String(singleThreadContext)]
                    )
                    if !hasUsedRecommendedSort && SortTypeSettingsUserDefaultsUtils.respectSubredditRecommendedCommentSortType {
                        if !postDetails.postListing.posts.isEmpty, let suggestedSort = SortType.Kind(rawValue: postDetails.postListing.posts[0].suggestedSort) {
                            await MainActor.run {
                                self.sortTypeKind =  suggestedSort
                                self.hasUsedRecommendedSort = true
                            }
                            await fetchPostAndComments(isRefreshWithContinuation: isRefreshWithContinuation, shouldLoadPost: shouldLoadPost, forceLoad: true)
                            return
                        }
                        self.hasUsedRecommendedSort = true
                    }
                } else {
                    postDetails = try await postDetailsRepository.fetchComments(
                        postId: postId,
                        queries: ["sort": sortTypeKind.rawValue]
                    )
                    if !hasUsedRecommendedSort && SortTypeSettingsUserDefaultsUtils.respectSubredditRecommendedCommentSortType {
                        if !postDetails.postListing.posts.isEmpty, let suggestedSort = SortType.Kind(rawValue: postDetails.postListing.posts[0].suggestedSort) {
                            await MainActor.run {
                                self.sortTypeKind =  suggestedSort
                                self.hasUsedRecommendedSort = true
                            }
                            await fetchPostAndComments(isRefreshWithContinuation: isRefreshWithContinuation, shouldLoadPost: shouldLoadPost, forceLoad: true)
                            return
                        }
                        self.hasUsedRecommendedSort = true
                    }
                }
            }
            
            try Task.checkCancellation()
            
            if shouldLoadPost {
                if postDetails.postListing.posts.isEmpty {
                    throw PostDetailsViewModelError.postFetchError
                }
                let post = postDetails.postListing.posts[0]
                await postProcessPost(post)
                
                await MainActor.run {
                    self.post = post
                }
            }
            
            if commentFilter == nil {
                await fetchCommentFilter()
            }
            
            let processedComments = postProcessComments(postDetails.comments)
            let commentsToBeAppendedToVisibleComments = pickVisibleComments(processedComments)
            
            try Task.checkCancellation()
            
            await MainActor.run {
                if isRefreshWithContinuation {
                    self.visibleComments.removeAll()
                    self.allComments.removeAll()
                }
                self.visibleComments.append(contentsOf: commentsToBeAppendedToVisibleComments)
                self.allComments.append(contentsOf: processedComments)
                
                hasMoreComments = postDetails.commentListing.commentMore?.children.isEmpty == false
                commentMore = postDetails.commentListing.commentMore
                
                self.isInitialLoading = false
                self.isLoadingMore = false
                self.lastLoadedSortTypeKind = self.sortTypeKind
                
                if isRefreshWithContinuation {
                    finishPullToRefresh()
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
                
                self.isInitialLoad = isInitailLoadCopy
                self.isInitialLoading = false
                self.isLoadingMore = false
            }
            print("Error fetching comments: \(error)")
        }
    }
    
    private func fetchPost() async throws {
        let postDetails: PostDetailsRootClass
        switch postDetailsInput {
        case .post(let post):
            postDetails = try await postDetailsRepository.fetchComments(
                postId: post.id,
                queries: ["sort": sortTypeKind.rawValue]
            )
        case .postAndCommentId(let postId, _):
            postDetails = try await postDetailsRepository.fetchComments(
                postId: postId,
                queries: ["sort": sortTypeKind.rawValue]
            )
        }
        
        try Task.checkCancellation()
        
        if postDetails.postListing.posts.isEmpty {
            throw PostDetailsViewModelError.postFetchError
        }
        let post = postDetails.postListing.posts[0]
        await postProcessPost(post)
        
        await MainActor.run {
            self.post = post
        }
    }
    
    private func postProcessPost(_ post: Post) async {
        MarkdownUtils.parseRedditImagesBlock(post)
        post.selftextProcessedMarkdown = MarkdownContent(post.selftext)
        
        if await historyPostsRepository.getIfExistInHistoryPostsAnonymous(account: account, postId: post.id, postHistoryType: .upvoted) {
            post.likes = 1
        } else if await historyPostsRepository.getIfExistInHistoryPostsAnonymous(account: account, postId: post.id, postHistoryType: .downvoted) {
            post.likes = -1
        }
        
        post.hidden = await historyPostsRepository.getIfExistInHistoryPostsAnonymous(account: account, postId: post.id, postHistoryType: .hidden)
        post.saved = await historyPostsRepository.getIfExistInHistoryPostsAnonymous(account: account, postId: post.id, postHistoryType: .saved)
    }
    
    public func fetchCommentsPagination() async {
        if await fetchMoreCommentsInCommentMore(commentMore: commentMore) {
            await MainActor.run {
                commentMore = nil
                hasMoreComments = false
            }
        }
    }
    
    // Pagination or "Load more comments"
    public func fetchMoreCommentsInCommentMore(commentMore: CommentMore?) async -> Bool {
        guard refreshPostsContinuation == nil else { return false }
        guard let post else { return false }
        guard let commentMore else { return false }
        
        do {
            try Task.checkCancellation()
            
            let moreChildren = try await postDetailsRepository.fetchMoreCommentsForCommentMore(
                params: ["link_id": post.name, "children": commentMore.children.joined(separator: ",")]
            )
            
            try Task.checkCancellation()
            
            if commentFilter == nil {
                await fetchCommentFilter()
            }
            
            let processedComments = postProcessComments(moreChildren.commentItems)
            let commentsToBeAppendedToVisibleComments = pickVisibleComments(processedComments)
            
            try Task.checkCancellation()
            
            await MainActor.run {
                guard let visibleIndex = visibleComments.index(id: commentMore.id) else { return }
                guard let allIndex = allComments.index(id: commentMore.id) else { return }
                
                // Remove the CommentMore item
                self.visibleComments.remove(at: visibleIndex)
                self.allComments.remove(at: allIndex)
                
                self.visibleComments.insert(contentsOf: commentsToBeAppendedToVisibleComments, at: visibleIndex)
                self.allComments.insert(contentsOf: processedComments, at: allIndex)
            }
            
            return true
        } catch {
            await MainActor.run {
                self.error = error
            }
            print("Error fetching more comments for CommentMore: \(error)")
            
            return false
        }
    }
    
    func pickVisibleComments(_ allCommentItems: [CommentItem]) -> [CommentItem] {
        var result: [CommentItem] = []
        var lastCollapsedDepth: Int? = nil
        allCommentItems.forEach { commentItem in
            switch commentItem {
            case .comment(let comment):
                if !(showTopLevelCommentsFirst && comment.depth != 0) {
                    if comment.isCollasped {
                        lastCollapsedDepth = comment.depth
                        result.append(commentItem)
                    } else {
                        if let depth = lastCollapsedDepth {
                            if depth < comment.depth {
                                // Child comment
                                comment.isCollasped = true
                            } else {
                                lastCollapsedDepth = nil
                                result.append(commentItem)
                            }
                        } else {
                            if showTopLevelCommentsFirst && comment.depth == 0 {
                                comment.isCollasped = true
                            }
                            result.append(commentItem)
                        }
                    }
                }
            case .more:
                if !(showTopLevelCommentsFirst && commentItem.depth != 0) {
                    if let depth = lastCollapsedDepth {
                        if depth >= commentItem.depth {
                            // Not a child CommentMore of a collapsed parent
                            lastCollapsedDepth = nil
                            result.append(commentItem)
                        }
                    } else {
                        result.append(commentItem)
                    }
                }
            }
        }
        
        return result
    }
    
    @MainActor
    func refreshPostAndCommentsWithContinuation() async {
        await withCheckedContinuation { continuation in
            refreshPostsContinuation = continuation
            lastLoadedSortTypeKind = nil
            loadPostAndCommentsTaskId = UUID()
        }
    }
    
    func refreshPostAndComments() {
        lastLoadedSortTypeKind = nil
        loadPostAndCommentsTaskId = UUID()
    }
    
    func resetPostAndCommentsLoadingState() async {
        await MainActor.run {
            isInitialLoad = true
            isInitialLoading = false
            isLoadingMore = false
            
            hasMoreComments = true
            if refreshPostsContinuation == nil {
                visibleComments.removeAll()
                allComments.removeAll()
            }
        }
    }
    
    func finishPullToRefresh() {
        refreshPostsContinuation?.resume()
        refreshPostsContinuation = nil
    }
    
    func postProcessComments(_ comments: [CommentItem]) -> [CommentItem] {
        var lastRemovedCommentDepth: Int? = nil
        return comments.compactMap {
            switch $0 {
            case .comment(let comment):
                let isCommentAllowed = CommentFilter.isCommentAllowed(comment, commentFilter)
                if isCommentAllowed {
                    if let depth = lastRemovedCommentDepth {
                        if depth < comment.depth {
                            // Child comment of a filtered out comment
                            print("Comment not allowed because it's a child of a filtered out comment")
                            return nil
                        } else {
                            lastRemovedCommentDepth = nil
                        }
                    }
                    print("Comment allowed")
                } else {
                    if commentFilter?.displayMode == .collapseComment {
                        print("Comment not allowed but collapsed")
                        comment.isCollasped = true
                        comment.isFilteredOut = true
                    } else {
                        lastRemovedCommentDepth = comment.depth
                        print("Comment not allowed")
                        return nil
                    }
                }
                modifyCommentBody(comment)
                comment.bodyProcessedMarkdown = MarkdownContent(comment.body)
                return $0
            case .more(let commentMore):
                if let depth = lastRemovedCommentDepth {
                    if depth < commentMore.depth {
                        if commentFilter?.displayMode != .collapseComment {
                            print("Comment more not allowed because it's a child of a filtered out comment")
                            return nil
                        }
                    }
                }
                print("Comment more allowed")
                return $0
            }
        }
    }
    
    func modifyCommentBody(_ comment: Comment) {
        MarkdownUtils.parseRedditImagesBlock(comment)
    }
    
    public func collapseComments(comment: Comment) {
        guard comment.hasReplies else {
            return
        }
        
        guard let index = visibleComments.index(id: comment.id) else { return }

        let parentDepth = comment.depth
        var endIndex = index + 1

        while endIndex < visibleComments.count {
            let item = visibleComments[endIndex]

            guard item.depth > (parentDepth ?? 0) else {
                break
            }
            
            if case .comment(let comment) = item {
                comment.isCollasped = true
            }

            endIndex += 1
        }

        comment.isCollasped = true
        visibleComments.removeSubrange((index + 1)..<endIndex)
    }
    
    public func expandComments(comment: Comment) {
        guard comment.hasReplies else {
            return
        }
        
        guard let index = visibleComments.index(id: comment.id),
              let parentIndexInAll = allComments.index(id: comment.id),
              let parentDepth = comment.depth else {
            return
        }

        var insertIndex = index + 1
        var childIndex = parentIndexInAll + 1

        while childIndex < allComments.count {
            let child = allComments[childIndex]

            // Stop when we reach a sibling or ancestor
            guard child.depth > parentDepth else {
                break
            }

            // Avoid inserting if already visible
            if !visibleComments.contains(where: { $0.id == child.id }) {
                if case .comment(let comment) = child {
                    comment.isCollasped = false
                }
                visibleComments.insert(child, at: insertIndex)
                insertIndex += 1
            } else {
                break
            }

            childIndex += 1
        }
        
        comment.isCollasped = false
        comment.hasExpandedBefore = true
    }
    
    func fetchCommentFilter() async {
        self.commentFilter = await postDetailsRepository.fetchCommentFilter(usageType: .subreddit, nameOfUsage: post?.subreddit ?? "")
    }
    
    func loadIcon(comment: Comment) {
        guard comment.authorIconUrlString == nil else { return }
        
        let startIndex = visibleComments.index(id: comment.id) ?? 0
        let commentBatch = Array(
            visibleComments[startIndex..<min(visibleComments.count, startIndex + UserProfileImageBatchLoader.batchSize)]
        ).compactMap { item -> Comment? in
            if case .comment(let comment) = item {
                return comment
            } else {
                return nil
            }
        }

        Task {
            let iconUrl = await UserProfileImageBatchLoader.shared.loadIcons(for: commentBatch)
            await MainActor.run {
                comment.authorIconUrlString = iconUrl
            }
        }
    }
    
    func loadIcon(isFromSubredditPostListing: Bool) async {
        guard let post else { return }
        guard post.subredditOrUserIconInPostDetails == nil else { return }
        
        if !isFromSubredditPostListing && post.subredditOrUserIcon != nil {
            await MainActor.run {
                post.subredditOrUserIconInPostDetails = post.subredditOrUserIcon
            }
            return
        }
        
        do {
            try await postDetailsRepository.loadPostIcon(post: post, isFromSubredditPostListing: isFromSubredditPostListing)
        } catch {
            print("Load icon failed")
        }
    }
    
    func changeSortTypeKind(sortTypeKind: SortType.Kind) {
        if sortTypeKind != self.sortTypeKind {
            self.sortTypeKind = sortTypeKind
            loadPostAndCommentsTaskId = UUID()
            if SortTypeSettingsUserDefaultsUtils.saveSortType && !SortTypeSettingsUserDefaultsUtils.respectSubredditRecommendedCommentSortType {
                UserDefaults.sortType?.set(sortTypeKind.rawValue, forKey: SortTypeUserDetailsUtils.postCommentSortTypeKey)
            }
        }
    }
    
    func insertSubmittedComment(_ comment: Comment, commentParent: CommentParent) {
        switch commentParent {
        case .post(parentPost: let post):
            guard post.id == self.post?.id else { return }
            self.visibleComments.insert(.comment(comment), at: 0)
        case .comment(parentComment: let parentComment):
            guard let visibleIndex = self.visibleComments.index(id: parentComment.id) else { return }
            guard let allIndex = self.allComments.index(id: parentComment.id) else { return }
            switch visibleComments[visibleIndex] {
            case .comment(let parentComment):
                if let replies = parentComment.replies {
                    replies.comments.insert(comment, at: 0)
                } else {
                    parentComment.replies = CommentListing(reply: comment)
                }
                self.allComments.insert(.comment(comment), at: allIndex + 1)
                if parentComment.isCollasped {
                    expandComments(comment: parentComment)
                } else {
                    self.visibleComments.insert(.comment(comment), at: visibleIndex + 1)
                }
            default:
                break
            }
        }
    }
    
    func editComment(_ comment: Comment, commentToBeEdited: Comment) {
        guard let allIndex = self.allComments.index(id: commentToBeEdited.id) else {
            return
        }
        switch allComments[allIndex] {
        case .comment(let oldComment):
            oldComment.bodyProcessedMarkdown = comment.bodyProcessedMarkdown
            oldComment.body = comment.body
            oldComment.mediaMetadata = comment.mediaMetadata
            oldComment.edited = true
        default:
            break
        }
    }
    
    func deleteComment(_ comment: Comment) {
        Task {
            do {
                try await postDetailsRepository.deleteComment(comment)
                
                await MainActor.run {
                    guard let allIndex = self.allComments.index(id: comment.id) else {
                        return
                    }
                    if comment.hasReplies {
                        switch self.allComments[allIndex] {
                        case .comment(let comment):
                            comment.author = "[deleted]"
                            comment.body = "[deleted]"
                            comment.bodyProcessedMarkdown = MarkdownContent("[deleted]")
                            comment.isSubmitter = false
                            comment.distinguished = ""
                        default:
                            break
                        }
                    } else {
                        self.allComments.remove(at: allIndex)
                        guard let visibleIndex = self.visibleComments.index(id: comment.id) else {
                            return
                        }
                        self.visibleComments.remove(at: visibleIndex)
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print(error)
            }
        }
    }
    
    func editPost(_ newPost: Post) {
        if let post {
            post.selftext = newPost.selftext
            post.selftextProcessedMarkdown = newPost.selftextProcessedMarkdown
            post.mediaMetadata = newPost.mediaMetadata
            post.edited = true
        }
    }
    
    func deletePost() {
        guard let post else {
            self.error = PostDetailsViewModelError.postNotLoadedError
            return
        }
        
        Task {
            do {
                try await postDetailsRepository.deletePost(post)
                
                await MainActor.run {
                    self.post?.author = "[deleted]"
                    self.post?.selftext = "[deleted]"
                    self.post?.selftextProcessedMarkdown = MarkdownContent("[deleted]")
                    self.post?.mediaMetadata = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print(error)
            }
        }
    }
    
    func toggleHidePost(onFinish: @escaping () -> Void) {
        guard let post else {
            self.error = PostDetailsViewModelError.postNotLoadedError
            return
        }
        
        guard !account.isAnonymous() else {
            toggleHidePostAnonymous(post, onFinish: onFinish)
            return
        }
        
        let previousHiddenState = post.hidden ?? false
        
        Task {
            do {
                try await postDetailsRepository.toggleHidePost(post)
                
                await MainActor.run {
                    self.post?.hidden = !previousHiddenState
                    onFinish()
                }
            } catch {
                await MainActor.run {
                    self.post?.hidden = previousHiddenState
                    self.error = error
                    onFinish()
                }
                print(error)
            }
        }
    }

    private func toggleHidePostAnonymous(_ post: Post, onFinish: @escaping () -> Void) {
        Task {
            try? await postDetailsRepository.toggleHidePostAnonymous(post)
            await MainActor.run {
                post.hidden = !post.hidden
                onFinish()
            }
        }
    }
    
    @MainActor
    func toggleSensitive(onFinish: @escaping () -> Void) {
        guard let post else {
            self.error = PostDetailsViewModelError.postNotLoadedError
            return
        }
        
        guard !account.isAnonymous() else {
            return
        }
        
        toggleSensitiveTask?.cancel()
        toggleSensitiveTask = Task {
            do {
                try await postDetailsRepository.toggleSensitive(post)
                do {
                    try Task.checkCancellation()
                    self.post?.over18.toggle()
                    
                    onFinish()
                } catch {
                    // Ignore
                }
            } catch {
                self.error = error
                print(error)
            }
            
            toggleSensitiveTask = nil
        }
    }
    
    @MainActor
    func toggleSpoiler(onFinish: @escaping () -> Void) {
        guard let post else {
            self.error = PostDetailsViewModelError.postNotLoadedError
            return
        }
        
        guard !account.isAnonymous() else {
            return
        }
        
        toggleSpoilerTask?.cancel()
        toggleSpoilerTask = Task {
            do {
                try await postDetailsRepository.toggleSpoiler(post)
                do {
                    try Task.checkCancellation()
                    self.post?.spoiler.toggle()
                    
                    onFinish()
                } catch {
                    // Ignore
                }
            } catch {
                self.error = error
                print(error)
            }
            
            toggleSpoilerTask = nil
        }
    }
    
    @MainActor
    func fetchFlairs(forceFetch: Bool = false) {
        guard flairs == nil else {
            return
        }
        
        guard let post else {
            self.error = PostDetailsViewModelError.postNotLoadedError
            return
        }
        
        guard !account.isAnonymous() else {
            return
        }
        
        Task {
            do {
                self.flairs = try await flairRepository.fetchFlairs(subreddit: post.subreddit)
            } catch {
                self.error = error
            }
        }
    }

    func selectFlair(_ flair: Flair) {
        guard let post else {
            self.error = PostDetailsViewModelError.postNotLoadedError
            return
        }
        
        guard !account.isAnonymous() else {
            return
        }
        
        selectFlairTask?.cancel()
        selectFlairTask = Task {
            do {
                try await postDetailsRepository.selectFlair(post: post, flair: flair)
                do {
                    try Task.checkCancellation()
                    try await fetchPost()
                } catch {
                    // Ignore
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print(error)
            }
            
            selectFlairTask = nil
        }
    }
    
    func insertIntoAppearedComments(_ commentItem: CommentItem) {
        self.appearedComments.removeAll {
            $0.id == commentItem.id
        }
        
        guard !self.appearedComments.isEmpty else {
            appearedComments.append(commentItem)
            return
        }
        
        if let index = self.allComments.index(id: commentItem.id) {
            var inserted: Bool = false
            for (i, comment) in self.appearedComments.enumerated() {
                if let appearedCommentIndex = self.allComments.index(id: comment.id), index < appearedCommentIndex {
                    self.appearedComments.insert(commentItem, at: i)
                    inserted = true
                    break
                }
            }
            if !inserted {
                self.appearedComments.append(commentItem)
            }
        } else {
            appearedComments.append(commentItem)
        }
    }
    
    func getNextParentComment() -> CommentItem? {
        for i in appearedComments.indices.reversed() {
            if appearedComments[i].depth == 0 && i >= 2 {
                return appearedComments[i]
            }
        }
        
        if appearedComments.isEmpty {
            return visibleComments.first
        } else {
            if let lastIndex = visibleComments.index(id: appearedComments[appearedComments.count - 1].id) {
                for i in lastIndex..<visibleComments.count {
                    if visibleComments[i].depth == 0 && visibleComments[i].isComment {
                        return visibleComments[i]
                    }
                }
            }
        }
        
        return nil
    }
    
    func getPreviousParentComment() -> CommentItem? {
        if appearedComments.isEmpty {
            return nil
        } else {
            if let firstIndex = visibleComments.index(id: appearedComments[0].id) {
                for i in (0..<firstIndex).reversed() {
                    if visibleComments[i].depth == 0 && visibleComments[i].isComment {
                        return visibleComments[i]
                    }
                }
            }
        }
        
        return nil
    }
    
    func getNextSearchedComment() -> CommentItem? {
        if let searchedComment {
            if let visibleIndex = visibleComments.index(id: searchedComment.id) {
                for i in visibleIndex + 1..<visibleComments.count {
                    if visibleComments[i].containsSearchQuery(searchQuery) {
                        setSearchedComment(visibleComments[i])
                        return visibleComments[i]
                    }
                }
            }
        }
        
        if appearedComments.isEmpty {
            for visibleComment in visibleComments {
                if visibleComment.containsSearchQuery(searchQuery) {
                    setSearchedComment(visibleComment)
                    return visibleComment
                }
            }
        } else {
            for i in appearedComments.indices.reversed() {
                if appearedComments[i].containsSearchQuery(searchQuery) {
                    setSearchedComment(appearedComments[i])
                    return appearedComments[i]
                }
            }
            
            if let lastIndex = visibleComments.index(id: appearedComments[appearedComments.count - 1].id) {
                for i in lastIndex..<visibleComments.count {
                    if visibleComments[i].containsSearchQuery(searchQuery) {
                        setSearchedComment(visibleComments[i])
                        return visibleComments[i]
                    }
                }
            }
        }
        
        return nil
    }
    
    func getPreviousSearchedComment() -> CommentItem? {
        if let searchedComment {
            if let visibleIndex = visibleComments.index(id: searchedComment.id) {
                for i in (0..<visibleIndex).reversed() {
                    if visibleComments[i].containsSearchQuery(searchQuery) {
                        setSearchedComment(visibleComments[i])
                        return visibleComments[i]
                    }
                }
            }
        }
        
        if !appearedComments.isEmpty, let firstIndex = visibleComments.index(id: appearedComments[0].id) {
            for i in (0..<firstIndex).reversed() {
                if visibleComments[i].containsSearchQuery(searchQuery) {
                    setSearchedComment(visibleComments[i])
                    return visibleComments[i]
                }
            }
        }
        
        return nil
    }
    
    private func setSearchedComment(_ comment: CommentItem) {
        withAnimation {
            searchedComment = comment
        }
    }
    
    @MainActor
    func approvePost() {
        guard let post else {
            return
        }
        
        Task {
            do {
                try await thingModerationRepository.approveThing(thingFullname: post.name)
                
                self.post?.approved = true
                self.post?.approvedBy = account.username
                self.post?.approvedAtUtc = Utils.getCurrentTimeEpoch()
                self.post?.removed = false
                self.post?.removedBy = ""
                self.post?.removedByCategory = ""
                self.post?.spam = false
            } catch {
                self.error = error
                print(error)
            }
        }
    }
    
    @MainActor
    func approveComment(_ comment: Comment) {
        Task {
            do {
                try await thingModerationRepository.approveThing(thingFullname: comment.name)
                
                guard let allIndex = self.allComments.index(id: comment.id) else {
                    return
                }
                switch allComments[allIndex] {
                case .comment(let oldComment):
                    oldComment.approved = true
                    oldComment.approvedBy = account.username
                    oldComment.approvedAtUtc = Utils.getCurrentTimeEpoch()
                    oldComment.removed = false
                    oldComment.spam = false
                default:
                    break
                }
            } catch {
                self.error = error
                print(error)
            }
        }
    }
    
    @MainActor
    func removePost(isSpam: Bool) {
        guard let post else {
            return
        }
        
        Task {
            do {
                try await thingModerationRepository.removeThing(thingFullname: post.name, isSpam: isSpam)
                
                self.post?.approved = false
                self.post?.approvedBy = ""
                self.post?.approvedAtUtc = 0
                self.post?.removed = true
                self.post?.removedBy = account.username
                self.post?.removedByCategory = "moderator"
                self.post?.spam = isSpam
            } catch {
                self.error = error
                print(error)
            }
        }
    }
    
    @MainActor
    func removeComment(_ comment: Comment, isSpam: Bool) {
        Task {
            do {
                try await thingModerationRepository.removeThing(thingFullname: comment.name, isSpam: isSpam)
                
                guard let allIndex = self.allComments.index(id: comment.id) else {
                    return
                }
                switch allComments[allIndex] {
                case .comment(let oldComment):
                    oldComment.approved = false
                    oldComment.approvedBy = ""
                    oldComment.approvedAtUtc = 0
                    oldComment.removed = true
                    oldComment.spam = isSpam
                default:
                    break
                }
            } catch {
                self.error = error
                print(error)
            }
        }
    }
    
    @MainActor
    func toggleSticky() {
        guard let post else {
            return
        }
        
        Task {
            do {
                try await thingModerationRepository.toggleSticky(post: post)
                
                self.post?.stickied = !(self.post?.stickied ?? false)
            } catch {
                self.error = error
                print(error)
            }
        }
    }
    
    @MainActor
    func toggleLockPost() {
        guard let post else {
            return
        }
        
        Task {
            do {
                try await thingModerationRepository.toggleLock(thingFullname: post.name, lock: !post.locked)
                
                self.post?.locked = !(self.post?.locked ?? false)
            } catch {
                self.error = error
                print(error)
            }
        }
    }
    
    @MainActor
    func toggleLockComment(_ comment: Comment) {
        Task {
            do {
                try await thingModerationRepository.toggleLock(thingFullname: comment.name, lock: !comment.locked)
                
                guard let allIndex = self.allComments.index(id: comment.id) else {
                    return
                }
                switch allComments[allIndex] {
                case .comment(let oldComment):
                    oldComment.locked.toggle()
                default:
                    break
                }
            } catch {
                self.error = error
                print(error)
            }
        }
    }
    
    @MainActor
    func toggleDistinguishAsMod() {
        guard let post else {
            return
        }
        
        Task {
            do {
                try await thingModerationRepository.toggleDistinguishAsMod(post: post)
                
                self.post?.distinguished = (self.post?.distinguished ?? "") == "moderator" ? "" : "moderator"
            } catch {
                self.error = error
                print(error)
            }
        }
    }
    
    func downloadMedia() {
        guard let post else {
            return
        }
        
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
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func downloadAllGalleryMedia() {
        guard let post else {
            return
        }
        
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
}
