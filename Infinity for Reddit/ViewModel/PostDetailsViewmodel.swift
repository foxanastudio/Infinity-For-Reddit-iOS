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

public class PostDetailsViewModel: ObservableObject {
    // MARK: - Properties
    @Published var post: Post?
    @Published var visibleComments: IdentifiedArrayOf<CommentItem> = []
    var allComments: IdentifiedArrayOf<CommentItem> = []
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
    private let account: Account
    private var commentMore: CommentMore?
    private var lastLoadedSortTypeKind: SortType.Kind? = nil
    private var commentFilter: CommentFilter?
    private var hasUsedRecommendedSort: Bool = false
    
    //User defaults
    private var showTopLevelCommentsFirst: Bool
    
    private let postDetailsRepository: PostDetailsRepositoryProtocol
    private let historyPostsRepository: HistoryPostsRepositoryProtocol
    
    private var refreshPostsContinuation: CheckedContinuation<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
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
        isContinueThread: Bool = false
    ) {
        self.account = account
        self.postDetailsInput = postDetailsInput
        self.sortTypeKind = SortTypeUserDetailsUtils.postComment
        self.postDetailsRepository = postDetailsRepository
        self.historyPostsRepository = historyPostsRepository
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
                fetchCommentFilter()
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
    
    private func postProcessPost(_ post: Post) async {
        MarkdownUtils.parseRedditImagesBlock(post)
        post.selftextProcessedMarkdown = MarkdownContent(post.selftext)
        
        if historyPostsRepository.getIfExistInHistoryPostsAnonymous(account: account, postId: post.id, postHistoryType: .upvoted) {
            post.likes = 1
        } else if historyPostsRepository.getIfExistInHistoryPostsAnonymous(account: account, postId: post.id, postHistoryType: .downvoted) {
            post.likes = -1
        }
        
        post.hidden = historyPostsRepository.getIfExistInHistoryPostsAnonymous(account: account, postId: post.id, postHistoryType: .hidden)
        post.saved = historyPostsRepository.getIfExistInHistoryPostsAnonymous(account: account, postId: post.id, postHistoryType: .saved)
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
                fetchCommentFilter()
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
    
    func fetchCommentFilter() {
        self.commentFilter = postDetailsRepository.fetchCommentFilter(usageType: .subreddit, nameOfUsage: post?.subreddit ?? "")
    }
    
    public func loadIcon(comment: Comment) {
        guard comment.authorIconUrl == nil else { return }
        
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
            
            if let iconUrl {
                await MainActor.run {
                    comment.authorIconUrl = iconUrl
                }
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
        guard let allIndex = self.allComments.index(id: commentToBeEdited.id) else { return }
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
}
