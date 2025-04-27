//
//  PostDetailsViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-23.
//

import Foundation
import Combine

@MainActor
public class PostDetailsViewModel: ObservableObject {
    // MARK: - Properties
    @Published var post: Post
    @Published var comments: [Comment] = []
    @Published var isSingleThread: Bool =  false
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMoreComments: Bool = true
    @Published var error: Error?
    private let account: Account
    private var postId: String?
    private var commentMore: CommentMore?
    private var isInitialLoad: Bool = true
    
    private var after: String? = nil
    
    public let postDetailsRepository: PostDetailsRepositoryProtocol
    
    // MARK: - Initializer
    init(account: Account, post: Post, postDetailsRepository: PostDetailsRepositoryProtocol) {
        self.account = account
        self.post = post
        self.postDetailsRepository = postDetailsRepository
    }
    
    // MARK: - Methods
    
    public func fetchComments() async {
        guard !isInitialLoading, !isLoadingMore, hasMoreComments else { return }
        
        if comments.isEmpty {
            isInitialLoading = true
        } else {
            isLoadingMore = true
        }
        
        if isInitialLoad {
            isInitialLoad = false
        }
        
        defer {
            self.isInitialLoading = false
            self.isLoadingMore = false
        }
        
        do {
            let postDetails = try await postDetailsRepository.fetchComments(
                postId: post.id,
                queries: ["after": after ?? ""]
            )
            
            self.comments.append(contentsOf: postDetails.comments)
            
            hasMoreComments = postDetails.commentListing.commentMore?.children.isEmpty == false
        } catch {
            self.error = error
            print("Error fetching comments: \(error)")
        }
    }
    
    /// Reloads posts from the first page
    func refreshPosts() async {
        isInitialLoad = true
        isInitialLoading = false
        isLoadingMore = false
        
        after = nil
        hasMoreComments = true
        comments = []
        
        await fetchComments()
    }
}
