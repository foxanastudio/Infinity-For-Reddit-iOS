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
    @Published var sortType: SortType
    @Published var loadPostsTaskId = UUID()
    @Published var postLayout: PostLayout
    
    @Published var appearedPosts: [Post] = []
    @Published var lazyModeScrolledPost: Post?
    
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
    
    // UserDefaults
    private var sensitiveContent: Bool
    private var spoilerContent: Bool
    private var readPostEnabled: Bool = true
    
    private let postListingRepository: PostListingRepositoryProtocol
    private let historyPostsRepository: HistoryPostsRepositoryProtocol
    
    private var refreshPostsContinuation: CheckedContinuation<Void, Never>?
    
    private var paginationTask: Task<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(
        postListingMetadata: PostListingMetadata,
        externalPostFilter: PostFilter?,
        postListingRepository: PostListingRepositoryProtocol,
        historyPostsRepository: HistoryPostsRepositoryProtocol
    ) {
        self.sortType = postListingMetadata.postListingType.savedSortType
        self.postListingMetadata = postListingMetadata
        self.externalPostFilter = externalPostFilter
        self.postListingRepository = postListingRepository
        self.historyPostsRepository = historyPostsRepository
        
        self.sensitiveContent = ContentSensitivityFilterUserDetailsUtils.sensitiveContent
        self.spoilerContent = ContentSensitivityFilterUserDetailsUtils.spoilerContent
        self.postLayout = postListingMetadata.postListingType.savedPostLayout
        
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                let sensitiveContent = UserDefaults.contentSensitivityFilter.bool(forKey: ContentSensitivityFilterUserDetailsUtils.sensitiveContentKey)
                let spoilerContent = UserDefaults.contentSensitivityFilter.bool(forKey: ContentSensitivityFilterUserDetailsUtils.spoilerContentKey)
                self?.setSensitiveContent(sensitiveContent)
                self?.setSpoilerContent(spoilerContent)
                
                let postLayout = postListingMetadata.postListingType.savedPostLayout
                Task { @MainActor in
                    if self?.postLayout != postLayout {
                        self?.postLayout = postLayout
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    
    public func initialLoadPosts() async {
        if sortType != lastLoadedSortType {
            await resetPostLoadingState()
        }
        
        guard isInitialLoad else {
            return
        }
        
        await loadPosts(isRefreshWithContinuation: refreshPostsContinuation != nil)
    }
    
    public func loadPostsPagination(index: Int) {
        guard paginationTask == nil else { return }
        
        guard index >= posts.count - 3 else { return }
        
        paginationTask = Task {
            defer {
                paginationTask = nil
            }
            await loadPosts()
        }
    }
    
    /// Fetches the next page of posts
    public func loadPosts(isRefreshWithContinuation: Bool = false) async {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else { return }
        
        let isInitailLoadCopy = isInitialLoad
        
        await MainActor.run {
            if posts.isEmpty {
                isInitialLoading = true
            } else {
                print("isloadingmore is true")
                isLoadingMore = true
            }
            
            if isInitialLoad {
                isInitialLoad = false
            }
        }
        
        do {
            try Task.checkCancellation()
            
            if case .anonymousFrontPage(let concatenatedSubscriptions) = postListingMetadata.postListingType {
                if let subscriptions = concatenatedSubscriptions {
                    if subscriptions.isEmpty {
                        // No anonymous subscriptions
                    } else {
                        postListingMetadata.pathComponents = ["subreddit": subscriptions]
                    }
                } else {
                    let fetchedSubscriptions = postListingRepository.getAnonymousSubscriptionsConcatenated()
                    postListingMetadata.postListingType = .anonymousFrontPage(concatenatedSubscriptions: fetchedSubscriptions)
                    if fetchedSubscriptions.isEmpty {
                        // No anonymous subscriptions
                    } else {
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
                    let fetchedSubscriptions = postListingRepository.getAnonymousCustomThemeSubredditsConcatenated(myCustomFeed: myCustomFeed)
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
                var queries = ["t": sortType.time?.rawValue ?? "", "limit": "100", "after": self.after ?? ""]
                if postListingMetadata.postListingType.canQuerySensitiveInAPICall {
                    queries["include_over_18"] = sensitiveContent ? "1" : "0"
                }
                postListing = try await postListingRepository.fetchPosts(
                    postListingType: postListingMetadata.postListingType,
                    pathComponents: ["sortType": sortType.type.rawValue].merging(postListingMetadata.pathComponents, uniquingKeysWith: { _, new in new }),
                    queries: queries.merging(postListingMetadata.queries ?? [:], uniquingKeysWith: { _, new in new }),
                    params: postListingMetadata.params
                )
            case .inQuery(let key):
                var queries = [key: sortType.type.rawValue, "t": sortType.time?.rawValue ?? "", "limit": "100", "after": self.after ?? ""]
                if postListingMetadata.postListingType.canQuerySensitiveInAPICall {
                    queries["include_over_18"] = sensitiveContent ? "1" : "0"
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
                    queries["include_over_18"] = sensitiveContent ? "1" : "0"
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
                fetchPostFilter()
            }
            
            let processedPosts = self.postProcessPosts(postListing.posts)
            
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
                self.error = error
                
                isInitialLoad = isInitailLoadCopy
                isInitialLoading = false
                isLoadingMore = false
            }
            
            print("Error fetching posts: \(error)")
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
    
    func postProcessPosts(_ posts: [Post]) -> [Post] {
        let readPostIds = historyPostsRepository.getReadPostsIdsByIds(
            readPostEnabled: readPostEnabled,
            account: AccountViewModel.shared.account,
            postIds: posts.map { $0.id }
        )
        let upvotedPostIdsAnonymous = AccountViewModel.shared.account.isAnonymous() ? historyPostsRepository.getHistoryPostsIdsByIdsAnonymous(
            account: AccountViewModel.shared.account,
            postIds: posts.map { $0.id },
            postHistoryType: .upvoted
        ) : Set<String>()
        let downvotedPostIdsAnonymous = AccountViewModel.shared.account.isAnonymous() ? historyPostsRepository.getHistoryPostsIdsByIdsAnonymous(
            account: AccountViewModel.shared.account,
            postIds: posts.map { $0.id },
            postHistoryType: .downvoted
        ) : Set<String>()
        let hiddenPostIdsAnonymous = AccountViewModel.shared.account.isAnonymous() ? historyPostsRepository.getHistoryPostsIdsByIdsAnonymous(
            account: AccountViewModel.shared.account,
            postIds: posts.map { $0.id },
            postHistoryType: .hidden
        ) : Set<String>()
        let savedPostIdsAnonymous = AccountViewModel.shared.account.isAnonymous() ? historyPostsRepository.getHistoryPostsIdsByIdsAnonymous(
            account: AccountViewModel.shared.account,
            postIds: posts.map { $0.id },
            postHistoryType: .saved
        ) : Set<String>()
        
        return posts.filter { post in
            print(PostFilter.isPostAllowed(post: post, postFilter: postFilter))
            return PostFilter.isPostAllowed(post: post, postFilter: postFilter) && !hiddenPostIdsAnonymous.contains(post.id)
        }.map {
            if !$0.selftext.isEmpty {
                modifyPostBody($0)
                $0.selftextProcessedMarkdown = MarkdownContent($0.selftext)
            }
            
            if readPostIds.contains($0.id) {
                $0.isRead = true
            }
            if upvotedPostIdsAnonymous.contains($0.id) {
                $0.likes = 1
            }
            if downvotedPostIdsAnonymous.contains($0.id) {
                $0.likes = -1
            }
            $0.saved = savedPostIdsAnonymous.contains($0.id)
            
            return $0
        }
    }
    
    func modifyPostBody(_ post: Post) {
        MarkdownUtils.parseRedditImagesBlock(post)
    }
    
    func fetchPostFilter() {
        self.postFilter = postListingRepository.getPostFilter(
            postListingType: postListingMetadata.postListingType,
            externalPostFilter: externalPostFilter
        )
        self.postFilter?.allowSensitive = sensitiveContent
        self.postFilter?.allowSpoiler = spoilerContent
    }
    
    func loadIcon(post: Post, displaySubredditIcon: Bool) async {
        guard post.subredditOrUserIcon == nil else { return }
        
        do {
            try await postListingRepository.loadIcon(post: post, displaySubredditIcon: displaySubredditIcon)
        } catch {
            print("Load icon failed")
        }
    }
    
    func changeSortTypeKind(_ sortTypeKind: SortType.Kind) {
        if sortTypeKind != self.sortType.type {
            self.sortType = self.sortType.with(type: sortTypeKind)
            loadPostsTaskId = UUID()
            if SortTypeSettingsUserDefaultsUtils.saveSortType {
                postListingMetadata.postListingType.saveSortType(sortType: SortType(type: sortTypeKind))
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
    
    func setSensitiveContent(_ sensitiveContent: Bool) {
        if sensitiveContent != self.sensitiveContent {
            self.sensitiveContent = sensitiveContent
            self.postFilter?.allowSensitive = sensitiveContent
            refreshPosts()
        }
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
    
    func insertIntoAppearedPosts(_ post: Post) {
        self.appearedPosts.removeAll {
            $0.id == post.id
        }
        
        guard !self.appearedPosts.isEmpty else {
            appearedPosts.append(post)
            return
        }
        
        if let index = self.posts.index(id: post.id) {
            var inserted: Bool = false
            for (i, appearedPost) in self.appearedPosts.enumerated() {
                if let appearedPostIndex = self.posts.index(id: appearedPost.id), index < appearedPostIndex {
                    self.appearedPosts.insert(post, at: i)
                    inserted = true
                    break
                }
            }
            if !inserted {
                self.appearedPosts.append(post)
            }
        } else {
            appearedPosts.append(post)
        }
    }
}
