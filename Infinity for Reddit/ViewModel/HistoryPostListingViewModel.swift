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

public class HistoryPostListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var posts: [Post] = []
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    @Published var error: Error?
    @Published var loadPostsTaskId = UUID()
    @Published var postLayout: PostLayout
    
    private var historyPostListingMetadata: HistoryPostListingMetadata
    private var externalPostFilter: PostFilter?
    private var postFilter: PostFilter?
    private var before: Int64? = nil
    
    // UserDefaults
    private var sensitiveContent: Bool
    private var spoilerContent: Bool
    
    private let historyPostListingRepository: HistoryPostListingRepositoryProtocol
    private let historyPostsRepository: HistoryPostsRepositoryProtocol
    
    private var refreshPostsContinuation: CheckedContinuation<Void, Never>?
    
    private var paginationTask: Task<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(
        historyPostListingMetadata: HistoryPostListingMetadata,
        externalPostFilter: PostFilter?,
        historyPostListingRepository: HistoryPostListingRepositoryProtocol,
        historyPostsRepository: HistoryPostsRepositoryProtocol,
        postFeedID: String
    ) {
        self.historyPostListingMetadata = historyPostListingMetadata
        self.externalPostFilter = externalPostFilter
        self.historyPostListingRepository = historyPostListingRepository
        self.historyPostsRepository = historyPostsRepository
        
        self.sensitiveContent = ContentSensitivityFilterUserDetailsUtils.sensitiveContent
        self.spoilerContent = ContentSensitivityFilterUserDetailsUtils.spoilerContent
        self.postLayout = PostLayoutUserDefaultsUtils.history
        
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                let sensitiveContent = UserDefaults.contentSensitivityFilter.bool(forKey: ContentSensitivityFilterUserDetailsUtils.sensitiveContentKey)
                let spoilerContent = UserDefaults.contentSensitivityFilter.bool(forKey: ContentSensitivityFilterUserDetailsUtils.spoilerContentKey)
                self?.setSensitiveContent(sensitiveContent)
                self?.setSpoilerContent(spoilerContent)
                
                let postLayout = historyPostListingMetadata.historyPostListingType.savedPostLayout
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
        guard isInitialLoad else {
            return
        }
        
        await loadPosts(isRefreshWithContinuation: refreshPostsContinuation != nil)
    }
    
    public func loadPostsPagination(index: Int) {
        guard paginationTask == nil else { return }
        
        guard index >= posts.count - 3 else { return }
        
        paginationTask = Task {
            defer { paginationTask = nil }
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
            
            let result = try await historyPostListingRepository.fetchPosts(
                historyPostListingType: historyPostListingMetadata.historyPostListingType,
                username: AccountViewModel.shared.account.username,
                before: before
            )
            
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
                    fetchPostFilter()
                }
                
                let processedPosts = self.postProcessPosts(postListing.posts)
                
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
                
                isInitialLoad = isInitailLoadCopy
                isInitialLoading = false
                isLoadingMore = false
            }
            
            print("Error fetching posts: \(error)")
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
    
    func postProcessPosts(_ posts: [Post]) -> [Post] {
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
            return PostFilter.isPostAllowed(post: post, postFilter: postFilter)
        }.map {
            if !$0.selftext.isEmpty {
                modifyPostBody($0)
                $0.selftextProcessedMarkdown = MarkdownContent($0.selftext)
            }
            
            if upvotedPostIdsAnonymous.contains($0.id) {
                $0.likes = 1
            }
            if downvotedPostIdsAnonymous.contains($0.id) {
                $0.likes = -1
            }
            $0.hidden = hiddenPostIdsAnonymous.contains($0.id)
            $0.saved = savedPostIdsAnonymous.contains($0.id)
            
            return $0
        }
    }
    
    func modifyPostBody(_ post: Post) {
        MarkdownUtils.parseRedditImagesBlock(post)
    }
    
    func fetchPostFilter() {
        self.postFilter = historyPostListingRepository.getPostFilter(
            historyPostListingType: historyPostListingMetadata.historyPostListingType,
            externalPostFilter: externalPostFilter
        )
        self.postFilter?.allowSensitive = sensitiveContent
        self.postFilter?.allowSpoiler = spoilerContent
    }
    
    func loadIcon(post: Post) async {
        guard post.subredditOrUserIcon == nil else { return }
        
        do {
            try await historyPostListingRepository.loadIcon(post: post)
        } catch {
            print("Load icon failed")
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
        historyPostListingMetadata.historyPostListingType.savePostLayout(postLayout: newLayout)
        postLayout = newLayout
    }
}
