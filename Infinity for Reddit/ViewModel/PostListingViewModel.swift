//
//  PostListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-05.
//

import Foundation
import Combine
import MarkdownUI

public class PostListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var posts: [Post] = []
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    private let account: Account
    private let postListingMetadata: PostListingMetadata
    private var isInitialLoad: Bool = true
    
    private var allPostIds = Set<String>()
    private var after: String? = nil
    private var cancellables = Set<AnyCancellable>()
    
    public let postListingRepository: PostListingRepositoryProtocol
    
    // MARK: - Initializer
    init(account: Account, postListingMetadata: PostListingMetadata, postListingRepository: PostListingRepositoryProtocol) {
        self.account = account
        self.postListingMetadata = postListingMetadata
        self.postListingRepository = postListingRepository
    }
    
    // MARK: - Methods
    
    /// Fetches the next page of posts
    public func loadPosts() {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else { return }
        
        if posts.isEmpty {
            isInitialLoading = true
        } else {
            isLoadingMore = true
        }
        
        if isInitialLoad {
            isInitialLoad = false
        }
        
        postListingRepository.fetchPosts(
            postListingType: postListingMetadata.postListingType,
            pathComponents: postListingMetadata.pathComponents,
            queries: ["limit": "100", "after": after ?? ""].merging(postListingMetadata.queries ?? [:], uniquingKeysWith: { _, new in new }),
            params: postListingMetadata.params
        )
        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .map { listingData -> (posts: [Post], after: String) in
            // Perform post-processing in the background thread
            let processedPosts = self.postProcessPosts(listingData.posts)
            return (processedPosts, listingData.after)
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            self?.isInitialLoading = false
            self?.isLoadingMore = false
            
            if case .failure(let error) = completion {
                print("Error fetching posts: \(error)")
            }
        }, receiveValue: { [weak self] (processedPosts, after) in
            guard let self = self else { return }
            if (processedPosts.isEmpty) {
                // No more posts
                hasMorePages = false
                self.after = nil
            } else {
                let realNewPosts = processedPosts.filter {
                    !self.allPostIds.contains($0.id)
                }
                
                self.after = after
                
                self.posts.append(contentsOf: realNewPosts)
                
                allPostIds.formUnion(
                    realNewPosts
                        .compactMap {
                            $0.id
                        }
                )
                
                hasMorePages = !(realNewPosts.isEmpty || after == nil || after.isEmpty)
            }
            print("fuck")
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
        hasMorePages = true
        posts = []
        
        loadPosts()
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
}
