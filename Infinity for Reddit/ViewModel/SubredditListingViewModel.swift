//
//  SubredditListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-19.
//

import Foundation

@MainActor
public class SubredditListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var query: String
    @Published var subreddits: [Subreddit] = []
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    @Published var error: Error?
    
    private var after: String? = nil
    
    public let subredditListingRepository: SubredditListingRepositoryProtocol
    
    // MARK: - Initializer
    init(query: String, subredditListingRepository: SubredditListingRepositoryProtocol) {
        self.query = query
        self.subredditListingRepository = subredditListingRepository
    }
    
    // MARK: - Methods
    
    public func initialLoadSubreddits() async {
        guard isInitialLoad else {
            return
        }
        
        await loadSubreddits()
    }
    
    public func loadSubreddits() async {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else { return }
        
        let isInitailLoadCopy = isInitialLoad
        
        if subreddits.isEmpty {
            isInitialLoading = true
        } else {
            isLoadingMore = true
        }
        
        if isInitialLoad {
            isInitialLoad = false
        }
        
        do {
            try Task.checkCancellation()
            
            let subredditListing = try await subredditListingRepository.fetchSubredditListing(queries: ["q": query, "limit": "100", "after": after ?? ""])
            
            try Task.checkCancellation()
            
            if (subredditListing.subreddits.isEmpty) {
                // No more subreddits
                hasMorePages = false
                self.after = nil
            } else {
                
                self.after = subredditListing.after
                
                self.subreddits.append(contentsOf: subredditListing.subreddits)
                hasMorePages = !(after == nil || after?.isEmpty == true)
            }
            
            isInitialLoading = false
            isLoadingMore = false
        } catch {
            await MainActor.run {
                self.error = error
                
                isInitialLoad = isInitailLoadCopy
                isInitialLoading = false
                isLoadingMore = false
            }
            
            print("Error fetching subreddits: \(error)")
        }
    }
    
    func refreshSubreddits() async {
        await MainActor.run {
            isInitialLoad = true
            isInitialLoading = false
            isLoadingMore = false
            
            after = nil
            hasMorePages = true
            subreddits = []
        }
        
        await initialLoadSubreddits()
    }
}
