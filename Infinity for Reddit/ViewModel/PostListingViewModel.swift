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

public class PostListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var posts: [Post] = []
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    @Published var error: Error?
    @Published var sortType: SortType
    @Published var loadPostsTaskId = UUID()
    
    private let postListingMetadata: PostListingMetadata
    private var lastLoadedSortType: SortType? = nil
    private var allPostIds = Set<String>()
    private var after: String? = nil
    
    public let postListingRepository: PostListingRepositoryProtocol
    
    private var refreshPostsContinuation: CheckedContinuation<Void, Never>?
    
    // MARK: - Initializer
    init(postListingMetadata: PostListingMetadata, postListingRepository: PostListingRepositoryProtocol) {
        self.sortType = SortType(
            type: postListingMetadata.postListingType.availableSortTypeKinds[0],
            time: postListingMetadata.postListingType.defaultSortTime
        )
        self.postListingMetadata = postListingMetadata
        self.postListingRepository = postListingRepository
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
        }
        
        do {
            try Task.checkCancellation()
            
            let postListing: PostListing
            switch postListingMetadata.postListingType.sortEmbeddingStyle {
            case .inPath:
                postListing = try await postListingRepository.fetchPosts(
                    postListingType: postListingMetadata.postListingType,
                    pathComponents: ["sortType": sortType.type.rawValue].merging(postListingMetadata.pathComponents, uniquingKeysWith: { _, new in new }),
                    queries: ["t": sortType.time?.rawValue ?? "", "limit": "100", "after": after ?? ""].merging(postListingMetadata.queries ?? [:], uniquingKeysWith: { _, new in new }),
                    params: postListingMetadata.params
                )
            case .inQuery(let key):
                postListing = try await postListingRepository.fetchPosts(
                    postListingType: postListingMetadata.postListingType,
                    pathComponents: postListingMetadata.pathComponents,
                    queries: [key: sortType.type.rawValue, "t": sortType.time?.rawValue ?? "", "limit": "100", "after": after ?? ""].merging(postListingMetadata.queries ?? [:], uniquingKeysWith: { _, new in new }),
                    params: postListingMetadata.params
                )
            }
            
            try Task.checkCancellation()
            
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
                    }
                    self.posts.append(contentsOf: realNewPosts)
                    hasMorePages = !(after == nil || after?.isEmpty == true)
                    
                    if isRefreshWithContinuation {
                        finishPullToRefresh()
                    }
                }
            }
            
            await MainActor.run {
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
                posts = []
            }
            
            allPostIds = Set<String>()
        }
    }
    
    func finishPullToRefresh() {
        refreshPostsContinuation?.resume()
        refreshPostsContinuation = nil
    }
    
    func postProcessPosts(_ posts: [Post]) -> [Post] {
        return posts.map {
            modifyPostBody($0)
            $0.selftextProcessedMarkdown = MarkdownContent($0.selftext)
            return $0
        }
    }
    
    func modifyPostBody(_ post: Post) {
        MarkdownUtils.parseRedditImagesBlock(post)
    }
    
    func loadIcon(post: Post, displaySubredditIcon: Bool) async {
        guard post.subredditOrUserIcon == nil else { return }
        
        do {
            try await postListingRepository.loadIcon(post: post, displaySubredditIcon: displaySubredditIcon)
        } catch {
            print("Load icon failed")
        }
    }
    
    func changeSortTypeKind(sortTypeKind: SortType.Kind) {
        if sortTypeKind != self.sortType.type {
            self.sortType = self.sortType.with(type: sortTypeKind)
            loadPostsTaskId = UUID()
        }
    }
    
    func changeSortType(sortType: SortType) {
        if sortType != self.sortType {
            self.sortType = sortType
            loadPostsTaskId = UUID()
        }
    }
}
