//
//  SubredditListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-19.
//

import Foundation
import Combine
import IdentifiedCollections

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
    @Published var sortType: SortType.Kind
    @Published var loadSubredditsTaskId = UUID()
    
    @Published var selectedSubreddits: IdentifiedArrayOf<Subreddit> = []
    
    private var after: String? = nil
    private var lastLoadedSortType: SortType.Kind? = nil
    
    // UserDefaults
    private var sensitiveContent: Bool
    
    let thingSelectionMode: ThingSelectionMode
    
    public let subredditListingRepository: SubredditListingRepositoryProtocol
    
    private var refreshSubredditsContinuation: CheckedContinuation<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(query: String, thingSelectionMode: ThingSelectionMode, subredditListingRepository: SubredditListingRepositoryProtocol) {
        self.query = query
        self.thingSelectionMode = thingSelectionMode
        self.sortType = SortTypeUserDetailsUtils.subredditListing
        self.subredditListingRepository = subredditListingRepository
        
        self.sensitiveContent = ContentSensitivityFilterUserDetailsUtils.sensitiveContent
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                let sensitiveContent = UserDefaults.contentSensitivityFilter.bool(forKey: ContentSensitivityFilterUserDetailsUtils.sensitiveContentKey)
                self?.setSensitiveContent(sensitiveContent)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    
    public func initialLoadSubreddits() async {
        if sortType != lastLoadedSortType {
            resetSubredditLoadingState()
        }
        
        guard isInitialLoad else {
            return
        }
        
        await loadSubreddits(isRefreshWithContinuation: refreshSubredditsContinuation != nil)
    }
    
    public func loadSubreddits(isRefreshWithContinuation: Bool = false) async {
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
            
            let subredditListing = try await subredditListingRepository.fetchSubredditListing(
                queries: ["q": query, "sort": sortType.rawValue, "limit": "100", "after": after ?? "", "include_over_18": sensitiveContent ? "1" : "0"]
            )
            
            try Task.checkCancellation()
            
            let allowedSubreddits = subredditListing.subreddits.filter {
                !($0.over18 && !sensitiveContent)
            }
            
            if (allowedSubreddits.isEmpty) {
                // No more subreddits
                self.hasMorePages = false
                self.after = nil
            } else {
                self.after = subredditListing.after
                if isRefreshWithContinuation {
                    self.subreddits.removeAll()
                }
                self.subreddits.append(contentsOf: allowedSubreddits)
                self.hasMorePages = !(after == nil || after?.isEmpty == true)
            }
            
            if isRefreshWithContinuation {
                finishPullToRefresh()
            }
            
            isInitialLoading = false
            isLoadingMore = false
            
            self.lastLoadedSortType = self.sortType
        } catch {
            self.error = error
            
            isInitialLoad = isInitailLoadCopy
            isInitialLoading = false
            isLoadingMore = false
            
            print("Error fetching subreddits: \(error)")
        }
    }
    
    func refreshSubredditsWithContinuation() async {
        await withCheckedContinuation { continuation in
            refreshSubredditsContinuation = continuation
            lastLoadedSortType = nil
            loadSubredditsTaskId = UUID()
        }
    }
    
    func refreshSubreddits() {
        lastLoadedSortType = nil
        loadSubredditsTaskId = UUID()
    }
    
    private func resetSubredditLoadingState() {
        isInitialLoad = true
        isInitialLoading = false
        isLoadingMore = false
        
        after = nil
        hasMorePages = true
        if refreshSubredditsContinuation == nil {
            subreddits = []
        }
    }
    
    func finishPullToRefresh() {
        refreshSubredditsContinuation?.resume()
        refreshSubredditsContinuation = nil
    }
    
    func changeSortTypeKind(_ sortTypeKind: SortType.Kind) {
        if sortTypeKind != self.sortType {
            self.sortType = sortTypeKind
            loadSubredditsTaskId = UUID()
            UserDefaults.sortType?.set(sortTypeKind.rawValue, forKey: SortTypeUserDetailsUtils.subredditListingSortTypeKey)
        }
    }
    
    func setSensitiveContent(_ sensitiveContent: Bool) {
        if sensitiveContent != self.sensitiveContent {
            self.sensitiveContent = sensitiveContent
            refreshSubreddits()
        }
    }
    
    func toggleSelection(subreddit: Subreddit) {
        if selectedSubreddits.index(id: subreddit.id) != nil {
            selectedSubreddits.remove(subreddit)
        } else {
            selectedSubreddits.append(subreddit)
        }
    }
}
