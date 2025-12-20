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
    @Published var comments: IdentifiedArrayOf<Comment> = []
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    @Published var error: Error? = nil
    @Published var sortType: SortType
    @Published var loadCommentsTaskId = UUID()
    
    private var after: String? = nil
    public let commentListingRepository: CommentListingRepositoryProtocol
    private let thingModerationRepository: ThingModerationRepositoryProtocol
    private let commentRepository: CommentRepositoryProtocol
    private let commentListingMetadata: CommentListingMetadata
    private var lastLoadedSortType: SortType? = nil
    
    private var refreshCommentsContinuation: CheckedContinuation<Void, Never>?
    
    // MARK: - Initializer
    init(commentListingMetadata: CommentListingMetadata,
         commentListingRepository: CommentListingRepositoryProtocol,
         thingModerationRepository: ThingModerationRepositoryProtocol,
         commentRepository: CommentRepositoryProtocol) {
        self.sortType = commentListingMetadata.commentListingType.savedSortType
        self.commentListingMetadata = commentListingMetadata
        self.commentListingRepository = commentListingRepository
        self.thingModerationRepository = thingModerationRepository
        self.commentRepository = commentRepository
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
            
            let commentListing: CommentListing
            switch commentListingMetadata.commentListingType {
            case .user:
                var queries: [String: String]
                if let time = sortType.time?.rawValue {
                    queries = ["sort": sortType.type.rawValue, "t": time, "limit": "100", "after": after ?? ""]
                } else {
                    queries = ["sort": sortType.type.rawValue, "limit": "100", "after": after ?? ""]
                }
                commentListing = try await commentListingRepository.fetchComments(
                    commentListingType: commentListingMetadata.commentListingType,
                    pathComponents: commentListingMetadata.pathComponents,
                    queries: queries.merging(commentListingMetadata.queries ?? [:], uniquingKeysWith: { _, new in new })
                )
            case .userSaved:
                commentListing = try await commentListingRepository.fetchComments(
                    commentListingType: commentListingMetadata.commentListingType,
                    pathComponents: commentListingMetadata.pathComponents,
                    queries: ["limit": "100", "after": after ?? ""].merging(commentListingMetadata.queries ?? [:], uniquingKeysWith: { _, new in new })
                )
            }
            
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
                }
                
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
            self.sortType = SortType(type: sortTypeKind)
            loadCommentsTaskId = UUID()
            commentListingMetadata.commentListingType.saveSortType(sortType: self.sortType)
        }
    }
    
    func changeSortType(sortType: SortType) {
        if sortType != self.sortType {
            self.sortType = sortType
            loadCommentsTaskId = UUID()
            commentListingMetadata.commentListingType.saveSortType(sortType: sortType)
        }
    }
    
    @MainActor
    func voteComment(_ comment: Comment, vote: Int) {
        guard !AccountViewModel.shared.account.isAnonymous(), let _ = comment.name else { return }
        
        Task {
            let previousVote = comment.likes
            
            var point: String
            let finalVote: Int
            if vote == comment.likes {
                point = "0"
                finalVote = 0
                comment.likes = 0
            } else {
                point = String(vote)
                finalVote = vote
                comment.likes = vote
            }
            self.objectWillChange.send()
            
            defer {
                self.objectWillChange.send()
            }
            
            do {
                try await commentRepository.voteComment(comment: comment, point: point)
                comment.likes = finalVote
            } catch {
                comment.likes = previousVote
                self.error = error
                print("Error voting comment: \(error)")
            }
        }
    }
    
    @MainActor
    func toggleSaveComment(_ comment: Comment, save: Bool) {
        guard !AccountViewModel.shared.account.isAnonymous(), let _ = comment.name else { return }
        
        Task {
            let previousSaved = comment.saved
            
            comment.saved = save
            
            self.objectWillChange.send()
            
            defer {
                self.objectWillChange.send()
            }
            
            do {
                try await commentRepository.saveComment(comment: comment, save: save)
            } catch {
                comment.saved = previousSaved
                self.error = error
                print("Error (un)saving comment: \(error)")
            }
        }
    }
    
    func editComment(_ comment: Comment, commentToBeEdited: Comment) {
        guard let index = self.comments.firstIndex(where: { $0.id == commentToBeEdited.id }) else { return }
        self.comments[index].bodyProcessedMarkdown = comment.bodyProcessedMarkdown
        self.comments[index].body = comment.body
        self.comments[index].mediaMetadata = comment.mediaMetadata
        self.comments[index].edited = true
    }
    
    func deleteComment(_ comment: Comment) {
        Task {
            do {
                try await commentListingRepository.deleteComment(comment)
                
                await MainActor.run {
                    guard let index = self.comments.index(id: comment.id) else {
                        return
                    }
                    self.comments.remove(at: index)
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print(error)
            }
        }
    }
    
    @MainActor
    func approveComment(_ comment: Comment) {
        Task {
            do {
                try await thingModerationRepository.approveThing(thingFullname: comment.name)
                
                guard let index = self.comments.index(id: comment.id) else {
                    return
                }
                comments[index].approved = true
                comments[index].approvedBy = AccountViewModel.shared.account.username
                comments[index].approvedAtUtc = Utils.getCurrentTimeEpoch()
                comments[index].removed = false
                comments[index].spam = false
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
                
                guard let index = self.comments.index(id: comment.id) else {
                    return
                }
                comments[index].approved = false
                comments[index].approvedBy = ""
                comments[index].approvedAtUtc = 0
                comments[index].removed = true
                comments[index].spam = isSpam
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
                
                guard let index = self.comments.index(id: comment.id) else {
                    return
                }
                comments[index].locked.toggle()
            } catch {
                self.error = error
                print(error)
            }
        }
    }
}
