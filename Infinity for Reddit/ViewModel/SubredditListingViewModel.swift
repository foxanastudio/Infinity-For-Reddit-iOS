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
    @Published var selectedSubscribedSubreddits: IdentifiedArrayOf<SubscribedSubredditData> = []
    @Published var selectedSubredditData: IdentifiedArrayOf<SubredditData> = []
    @Published var selectedSubredditsInCustomFeed: IdentifiedArrayOf<SubredditInCustomFeed> = []
    
    private var after: String? = nil
    private var lastLoadedSortType: SortType.Kind? = nil
    
    let thingSelectionMode: ThingSelectionMode
    
    public let subredditListingRepository: SubredditListingRepositoryProtocol
    
    private var refreshSubredditsContinuation: CheckedContinuation<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(query: String, thingSelectionMode: ThingSelectionMode, subredditListingRepository: SubredditListingRepositoryProtocol) {
        self.query = query
        self.thingSelectionMode = thingSelectionMode
        switch thingSelectionMode {
        case .subredditAndUserMultiSelection(let selectedSubredditsAndUsers, _):
            var selectedSubscribedSubreddits = IdentifiedArrayOf<SubscribedSubredditData>()
            var selectedSubredditData = IdentifiedArrayOf<SubredditData>()
            var selectedSubredditsInCustomFeed = IdentifiedArrayOf<SubredditInCustomFeed>()
            
            for item in selectedSubredditsAndUsers {
                switch item {
                case .subscribedSubreddit(let subscribedSubredditData):
                    selectedSubscribedSubreddits.append(subscribedSubredditData)
                case .subreddit(let subredditData):
                    selectedSubredditData.append(subredditData)
                case .subredditInCustomFeed(let subredditInCustomFeed):
                    selectedSubredditsInCustomFeed.append(subredditInCustomFeed)
                case .subredditInAnonymousCustomFeed(let anonymousCustomFeedSubreddit):
                    selectedSubredditsInCustomFeed.append(SubredditInCustomFeed(name: anonymousCustomFeedSubreddit.subredditName))
                case .subscribedUser(let subscribedUserData):
                    break
                case .user(_):
                    break
                case .myCustomFeed(_):
                    break
                }
            }
            
            self.selectedSubscribedSubreddits = selectedSubscribedSubreddits
            self.selectedSubredditData = selectedSubredditData
            self.selectedSubredditsInCustomFeed = selectedSubredditsInCustomFeed
        default:
            break
        }
        self.sortType = SortTypeUserDetailsUtils.subredditListing
        self.subredditListingRepository = subredditListingRepository
        
        NotificationCenter.default.publisher(for: Notification.Name.accountAllowSensitiveChanged)
            .sink { [weak self] _ in
                self?.sensitiveContentChanged()
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
        
        let isInitialLoadCopy = isInitialLoad
        
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
                queries: [
                    "q": query,
                    "sort": sortType.rawValue,
                    "limit": "100",
                    "after": after ?? "",
                    "include_over_18": AccountViewModel.shared.account.allowSensitive ? "1" : "0"
                ]
            )
            
            try Task.checkCancellation()
            
            let allowedSubreddits = subredditListing.subreddits.filter {
                !($0.over18 && !AccountViewModel.shared.account.allowSensitive)
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
            
            isInitialLoad = isInitialLoadCopy
            isInitialLoading = false
            isLoadingMore = false
            
            printInDebugOnly("Error fetching subreddits: \(error)")
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
    
    func sensitiveContentChanged() {
        refreshSubreddits()
    }
    
    func toggleSelection(subreddit: Subreddit) {
        if selectedSubreddits.index(id: subreddit.id) != nil {
            selectedSubreddits.remove(subreddit)
        } else if selectedSubredditData.index(id: subreddit.id) != nil {
            selectedSubredditData.remove(id: subreddit.id)
        } else if selectedSubscribedSubreddits.index(id: subreddit.id) != nil {
            selectedSubscribedSubreddits.remove(id: subreddit.id)
        } else if selectedSubredditsInCustomFeed.index(id: subreddit.name) != nil {
            selectedSubredditsInCustomFeed.remove(id: subreddit.name)
        } else {
            selectedSubreddits.append(subreddit)
        }
    }
}
