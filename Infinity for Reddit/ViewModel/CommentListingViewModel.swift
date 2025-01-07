//
//  CommentListingViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-15.
//

import Foundation
import Combine

public class CommentListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var comments: [Comment] = []
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    
    private var isInitialLoad: Bool = true
    private var after: String? = nil
    public let commentListingRepository: CommentListingRepositoryProtocol
    private let commentListingMetadata: CommentListingMetadata
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(commentListingMetadata: CommentListingMetadata, commentListingRepository: CommentListingRepositoryProtocol) {
        self.commentListingMetadata = commentListingMetadata
        self.commentListingRepository = commentListingRepository
    }
    
    // MARK: - Methods
    
    /// Fetches the next page of comments
    public func loadComments(account: Account) {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else { return }
        
        if comments.isEmpty {
            isInitialLoading = true
        } else {
            isLoadingMore = true
        }
        
        if isInitialLoad {
            isInitialLoad = false
        }
        
        commentListingRepository.fetchComments(commentListingType: commentListingMetadata.commentListingType, pathComponents: commentListingMetadata.pathComponents, queries: ["limit": "100", "after": after ?? ""].merging(commentListingMetadata.queries ?? [:], uniquingKeysWith: { _, new in new }), params: commentListingMetadata.params)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .map { listingData -> (comments: [Comment], after: String?) in
                // Perform post-processing in the background thread
                let processedComments = self.postProcessComments(listingData.comments)
                return (processedComments, listingData.after)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isInitialLoading = false
                self?.isLoadingMore = false
                
                if case .failure(let error) = completion {
                    print("Error fetching comments: \(error)")
                }
            }, receiveValue: { [weak self] (processedComments, after) in
                guard let self = self else { return }
                if (processedComments.isEmpty) {
                    // No more comments
                    hasMorePages = false
                    self.after = nil
                } else {
                    self.after = after
                    self.comments.append(contentsOf: processedComments)
                    self.hasMorePages = !(processedComments.isEmpty || after == nil || after?.isEmpty == true)
                }
                print("comments")
            })
            .store(in: &cancellables)
    }
    
    /// Reloads posts from the first page
    func refreshComments(account: Account) {
        // This is for user switching accounts. We have to force clear all load
        cancellables.forEach { $0.cancel() }
        
        isInitialLoad = true
        isInitialLoading = false
        isLoadingMore = false
        
        after = nil
        hasMorePages = true
        comments = []
        
        loadComments(account: account)
    }
    
    func postProcessComments(_ comments: [Comment]) -> [Comment] {
        return comments.map { modifyCommentBody($0) }
    }
    
    func modifyCommentBody(_ comment: Comment) -> Comment {
        comment.body = MarkdownUtils.replaceImageURL(comment)
        comment.body = MarkdownUtils.replaceGifURL(comment)
        
        return comment
    }
}
