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
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    @Published var error: Error?
    private let postListingMetadata: PostListingMetadata
    
    private var allPostIds = Set<String>()
    private var after: String? = nil
    
    public let postListingRepository: PostListingRepositoryProtocol
    
    // MARK: - Initializer
    init(postListingMetadata: PostListingMetadata, postListingRepository: PostListingRepositoryProtocol) {
        self.postListingMetadata = postListingMetadata
        self.postListingRepository = postListingRepository
    }
    
    // MARK: - Methods
    
    public func initialLoadPosts() async {
        guard isInitialLoad else {
            return
        }
        
        await loadPosts()
    }
    
    /// Fetches the next page of posts
    public func loadPosts() async {
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
            
            let postListing = try await postListingRepository.fetchPosts(
                postListingType: postListingMetadata.postListingType,
                pathComponents: postListingMetadata.pathComponents,
                queries: ["limit": "100", "after": after ?? ""].merging(postListingMetadata.queries ?? [:], uniquingKeysWith: { _, new in new }),
                params: postListingMetadata.params
            )
            
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
                    self.posts.append(contentsOf: realNewPosts)
                    hasMorePages = !(after == nil || after?.isEmpty == true)
                }
            }
            
            await MainActor.run {
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
    
    /// Reloads posts from the first page
    func refreshPosts() async {
        await MainActor.run {
            isInitialLoad = true
            isInitialLoading = false
            isLoadingMore = false
            
            after = nil
            hasMorePages = true
            posts = []
        }
        
        await initialLoadPosts()
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
