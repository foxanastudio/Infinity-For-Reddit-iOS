//
//  PostDetailsViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-23.
//

import Foundation
import Combine

public class PostDetailsViewModel: ObservableObject {
    // MARK: - Properties
    @Published var post: Post
    @Published var comments: [Comment] = []
    @Published var isSingleThread: Bool =  false
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMoreComments: Bool = true
    private let account: Account
    private var postId: String?
    private var commentMore: CommentMore?
    private var isInitialLoad: Bool = true
    
    private var after: String? = nil
    private var cancellables = Set<AnyCancellable>()
    
    public let postDetailsRepository: PostDetailsRepositoryProtocol
    
    // MARK: - Initializer
    init(account: Account, post: Post, postDetailsRepository: PostDetailsRepositoryProtocol) {
        self.account = account
        self.post = post
        self.postDetailsRepository = postDetailsRepository
    }
    
    // MARK: - Methods
    
    public func fetchComments() {
        guard !isInitialLoading, !isLoadingMore, hasMoreComments else { return }
        
        if comments.isEmpty {
            isInitialLoading = true
        } else {
            isLoadingMore = true
        }
        
        if isInitialLoad {
            isInitialLoad = false
        }
        
        postDetailsRepository.fetchComments(
            postId: post.id,
            queries: ["after": after ?? ""]
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            self?.isInitialLoading = false
            self?.isLoadingMore = false
            
            if case .failure(let error) = completion {
                print("Error fetching comments: \(error)")
            }
        }, receiveValue: { [weak self] postDetails in
            guard let self = self else { return }
            self.comments.append(contentsOf: postDetails.commentListing.comments)
            
            hasMoreComments = postDetails.commentListing.commentMore?.children.isEmpty == false
            print(postDetails.commentListing.comments.count)
        })
        .store(in: &cancellables)
    }
    
    /// Reloads posts from the first page
    func refreshPosts() {
        // This is for user switching accounts. We have to force clear all load
        cancellables.forEach { $0.cancel() }
        
        isInitialLoad = true
        isInitialLoading = false
        isLoadingMore = false
        
        after = nil
        hasMoreComments = true
        comments = []
        
        fetchComments()
    }
}
