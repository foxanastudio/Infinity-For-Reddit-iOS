//
//  CommentListingViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-15.
//

import Foundation
import Combine
import MarkdownUI
import IdentifiedCollections

public class CommentListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var comments: [Comment] = []
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    @Published var error: Error? = nil
    @Published var sortType: SortType
    @Published var loadCommentsTaskId = UUID()
    
    private var after: String? = nil
    public let commentListingRepository: CommentListingRepositoryProtocol
    private let commentListingMetadata: CommentListingMetadata
    private var lastLoadedSortType: SortType? = nil
    
    private var refreshCommentsContinuation: CheckedContinuation<Void, Never>?
    
    // MARK: - Initializer
    init(commentListingMetadata: CommentListingMetadata, commentListingRepository: CommentListingRepositoryProtocol) {
        self.sortType = commentListingMetadata.commentListingType.savedSortType
        self.commentListingMetadata = commentListingMetadata
        self.commentListingRepository = commentListingRepository
    }
    
    // MARK: - Methods
    
    public func initialLoadComments() async {
        if sortType != lastLoadedSortType {
            await resetCommentLoadingState()
        }
        
        guard isInitialLoad else {
            return
        }
        
        await loadComments(isRefreshWithContinuation: refreshCommentsContinuation != nil)
    }
    
    /// Fetches the next page of comments
    public func loadComments(isRefreshWithContinuation: Bool = false) async {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else { return }
        
        let isInitailLoadCopy = isInitialLoad
        
        await MainActor.run {
            if comments.isEmpty {
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
            
            let commentListing = try await commentListingRepository.fetchComments(
                commentListingType: commentListingMetadata.commentListingType,
                pathComponents: commentListingMetadata.pathComponents,
                queries: ["sort": sortType.type.rawValue, "t": sortType.time?.rawValue ?? "", "limit": "100", "after": after ?? ""].merging(commentListingMetadata.queries ?? [:], uniquingKeysWith: { _, new in new }),
                params: commentListingMetadata.params)
            
            try Task.checkCancellation()
            
            let processedComments = self.postProcessComments(commentListing.comments)
            
            try Task.checkCancellation()
            
            await MainActor.run {
                if (processedComments.isEmpty) {
                    // No more comments
                    hasMorePages = false
                    self.after = nil
                } else {
                    self.after = commentListing.after
                    if isRefreshWithContinuation {
                        self.comments.removeAll()
                    }
                    self.comments.append(contentsOf: processedComments)
                    self.hasMorePages = !(processedComments.isEmpty || after == nil || after?.isEmpty == true)
                    
                    if isRefreshWithContinuation {
                        finishPullToRefresh()
                    }
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
            
            print("Error fetching comments: \(error)")
        }
    }
    
    @MainActor
    func refreshCommentsWithContinuation() async {
        await withCheckedContinuation { continuation in
            refreshCommentsContinuation = continuation
            lastLoadedSortType = nil
            loadCommentsTaskId = UUID()
        }
    }
    
    func refreshComments() {
        lastLoadedSortType = nil
        loadCommentsTaskId = UUID()
    }
    
    private func resetCommentLoadingState() async {
        await MainActor.run {
            isInitialLoad = true
            isInitialLoading = false
            isLoadingMore = false
            
            after = nil
            hasMorePages = true
            if refreshCommentsContinuation == nil {
                comments = []
            }
        }
    }
    
    func finishPullToRefresh() {
        refreshCommentsContinuation?.resume()
        refreshCommentsContinuation = nil
    }
    
    func postProcessComments(_ comments: [Comment]) -> [Comment] {
        return comments.map {
            modifyCommentBody($0)
            $0.bodyProcessedMarkdown = MarkdownContent($0.body)
            return $0
        }
    }
    
    func modifyCommentBody(_ comment: Comment) {
        MarkdownUtils.parseRedditImagesBlock(comment)
    }
    
    func changeSortTypeKind(sortTypeKind: SortType.Kind) {
        if sortTypeKind != self.sortType.type {
            self.sortType = self.sortType.with(type: sortTypeKind)
            loadCommentsTaskId = UUID()
            commentListingMetadata.commentListingType.saveSortType(sortType: SortType(type: sortTypeKind))
        }
    }
    
    func changeSortType(sortType: SortType) {
        if sortType != self.sortType {
            self.sortType = sortType
            loadCommentsTaskId = UUID()
            commentListingMetadata.commentListingType.saveSortType(sortType: sortType)
        }
    }
}
