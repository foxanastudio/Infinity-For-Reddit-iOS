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
    @Published var listingData: ListingData?
    @Published var isLoading: Bool = false
    @Published var hasMorePages: Bool = true
    
    private var after: String? = nil
    private let pageSize: Int = 100
    private var cancellables = Set<AnyCancellable>()
    
    public let postListingRepository: PostListingRepositoryProtocol
    
    // MARK: - Initializer
    init(postListingRepository: PostListingRepositoryProtocol) {
        self.postListingRepository = postListingRepository
    }
    
    // MARK: - Methods
    
    /// Fetches the next page of posts
    public func loadPosts() {
        guard !isLoading, hasMorePages else { return }
        
        isLoading = true
        postListingRepository.fetchPosts(postListingType: .frontPage, limit: 100)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching posts: \(error)")
                }
            }, receiveValue: { [weak self] newPosts in
                guard let self = self else { return }
                //self.posts.append(contentsOf: newPosts)
                print("fuck")
            })
            .store(in: &cancellables)
    }
    
    /// Reloads posts from the first page
    func refreshPosts() {
        after = nil
        hasMorePages = true
        listingData = nil
        loadPosts()
    }
}
