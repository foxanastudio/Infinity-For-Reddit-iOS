//
//  PostListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-05.
//

import Foundation
import Combine

public class PostListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var posts: [Post] = []
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    private let postListingMetadata: PostListingMetadata
    private var isInitialLoad: Bool = true
    
    private var allPostIds = Set<String>()
    private var after: String? = nil
    private var cancellables = Set<AnyCancellable>()
    
    public let postListingRepository: PostListingRepositoryProtocol
    
    // MARK: - Initializer
    init(postListingMetadata: PostListingMetadata, postListingRepository: PostListingRepositoryProtocol) {
        self.postListingMetadata = postListingMetadata
        self.postListingRepository = postListingRepository
    }
    
    // MARK: - Methods
    
    /// Fetches the next page of posts
    public func loadPosts(account: Account) {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else { return }
        
        if posts.isEmpty {
            isInitialLoading = true
        } else {
            isLoadingMore = true
        }
        
        if isInitialLoad {
            postListingRepository.setAccount(account)
            isInitialLoad = false
        }
        
        postListingRepository.fetchPosts(
            postListingType: postListingMetadata.postListingType,
            pathComponents: postListingMetadata.pathComponents,
            queries: ["limit": "100", "after": after ?? ""].merging(postListingMetadata.queries ?? [:], uniquingKeysWith: { _, new in new }),
            params: postListingMetadata.params
        )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isInitialLoading = false
                self?.isLoadingMore = false
                
                if case .failure(let error) = completion {
                    print("Error fetching posts: \(error)")
                }
            }, receiveValue: { [weak self] listingData in
                guard let self = self else { return }
                if (listingData.posts.isEmpty) {
                    // No more posts
                    hasMorePages = false
                    after = nil
                } else {
                    let realNewPosts = listingData.posts.filter {
                        !self.allPostIds.contains($0.id)
                    }
                    
                    after = listingData.after
                    
                    self.posts.append(contentsOf: realNewPosts)
                    
                    allPostIds.formUnion(
                        realNewPosts
                            .compactMap {
                                $0.id
                            }
                    )
                    
                    hasMorePages = !(realNewPosts.isEmpty || listingData.after == nil || listingData.after.isEmpty)
                }
                print("fuck")
            })
            .store(in: &cancellables)
    }
    
    /// Reloads posts from the first page
    func refreshPosts(account: Account) {
        // This is for user switching accounts. We have to force clear all load
        cancellables.forEach { $0.cancel() }
        
        isInitialLoad = true
        isInitialLoading = false
        isLoadingMore = false
        
        after = nil
        hasMorePages = true
        posts = []
        
        loadPosts(account: account)
    }
}
