//
//  UserListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-22.
//

import Foundation
import Combine
import IdentifiedCollections

@MainActor
public class UserListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var query: String
    @Published var users: [User] = []
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var error: Error?
    @Published var sortType: SortType.Kind
    @Published var loadUsersTaskId = UUID()
    
    @Published var selectedUsers: IdentifiedArrayOf<User> = []
    @Published var selectedSubscribedUsers: IdentifiedArrayOf<SubscribedUserData> = []
    @Published var selectedUserData: IdentifiedArrayOf<UserData> = []
    @Published var selectedUserSubredditsInCustomFeed: IdentifiedArrayOf<SubredditInCustomFeed> = []
    
    var hasMorePages: Bool {
        isInitialLoad || !(after == nil || after?.isEmpty == true)
    }
    
    var isPullToRefreshing: Bool {
        refreshUsersContinuation != nil
    }
    
    private var after: String? = nil
    private var lastLoadedSortType: SortType.Kind? = nil
    
    let thingSelectionMode: ThingSelectionMode
    
    public let userListingRepository: UserListingRepositoryProtocol
    
    private var refreshUsersContinuation: CheckedContinuation<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(query: String, thingSelectionMode: ThingSelectionMode, userListingRepository: UserListingRepositoryProtocol) {
        self.query = query
        self.thingSelectionMode = thingSelectionMode
        switch thingSelectionMode {
        case .subredditAndUserMultiSelection(let selectedSubredditsAndUsers, _):
            var selectedSubscribedUsers = IdentifiedArrayOf<SubscribedUserData>()
            var selectedUserData = IdentifiedArrayOf<UserData>()
            var selectedUserSubredditsInCustomFeed = IdentifiedArrayOf<SubredditInCustomFeed>()
            
            for item in selectedSubredditsAndUsers {
                switch item {
                case .subscribedSubreddit:
                    break
                case .subreddit:
                    break
                case .subredditInCustomFeed(let subredditInCustomFeed):
                    selectedUserSubredditsInCustomFeed.append(subredditInCustomFeed)
                case .subredditInAnonymousCustomFeed(let anonymousCustomFeedSubreddit):
                    selectedUserSubredditsInCustomFeed.append(SubredditInCustomFeed(name: anonymousCustomFeedSubreddit.subredditName))
                case .subscribedUser(let subscribedUserData):
                    selectedSubscribedUsers.append(subscribedUserData)
                case .user(let userData):
                    selectedUserData.append(userData)
                case .myCustomFeed:
                    break
                }
            }
            
            self.selectedSubscribedUsers = selectedSubscribedUsers
            self.selectedUserData = selectedUserData
            self.selectedUserSubredditsInCustomFeed = selectedUserSubredditsInCustomFeed
        default:
            break
        }
        self.sortType = SortTypeUserDetailsUtils.userListing
        self.userListingRepository = userListingRepository
        
        NotificationCenter.default.publisher(for: Notification.Name.accountAllowSensitiveChanged)
            .sink { [weak self] _ in
                self?.sensitiveContentChanged()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    
    public func initialLoadUsers() async {
        if sortType != lastLoadedSortType {
            resetUserLoadingState()
        }
        
        guard isInitialLoad else {
            return
        }
        
        await loadUsers(isRefreshWithContinuation: refreshUsersContinuation != nil)
    }
    
    public func loadUsers(isRefreshWithContinuation: Bool = false) async {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else { return }
        
        let isInitialLoadCopy = isInitialLoad
        
        if users.isEmpty {
            isInitialLoading = true
        } else {
            isLoadingMore = true
        }
        
        if isInitialLoad {
            isInitialLoad = false
        }
        
        do {
            try Task.checkCancellation()
            
            let userListing = try await userListingRepository.fetchUserListing(
                queries: [
                    "q": query,
                    "type": "user",
                    "sort": sortType.rawValue,
                    "limit": "100",
                    "after": isRefreshWithContinuation ? "" : (after ?? ""),
                    "include_over_18": AccountViewModel.shared.account.allowSensitive ? "1" : "0"
                ]
            )
            
            try Task.checkCancellation()
            
            if (userListing.users.isEmpty) {
                // No more users
                self.after = nil
            } else {
                self.after = userListing.after
                if isRefreshWithContinuation {
                    self.users.removeAll()
                }
                self.users.append(contentsOf: userListing.users)
            }
            
            if isRefreshWithContinuation {
                finishPullToRefresh()
            }
            
            isInitialLoading = false
            isLoadingMore = false
            
            self.lastLoadedSortType = self.sortType
        } catch {
            self.error = error
            
            if isRefreshWithContinuation {
                finishPullToRefresh()
            } else {
                isInitialLoad = isInitialLoadCopy
            }
            
            isInitialLoading = false
            isLoadingMore = false
            
            printInDebugOnly("Error fetching users: \(error)")
        }
    }
    
    func refreshUsersWithContinuation() async {
        await withCheckedContinuation { continuation in
            refreshUsersContinuation = continuation
            lastLoadedSortType = nil
            loadUsersTaskId = UUID()
        }
    }
    
    func refreshUsers() {
        lastLoadedSortType = nil
        loadUsersTaskId = UUID()
    }
    
    private func resetUserLoadingState() {
        isInitialLoad = true
        isInitialLoading = false
        isLoadingMore = false
        
        if refreshUsersContinuation == nil {
            after = nil
            users = []
        }
    }
    
    func finishPullToRefresh() {
        refreshUsersContinuation?.resume()
        refreshUsersContinuation = nil
    }
    
    func changeSortTypeKind(_ sortTypeKind: SortType.Kind) {
        if sortTypeKind != self.sortType {
            self.sortType = sortTypeKind
            loadUsersTaskId = UUID()
            UserDefaults.sortType?.set(sortTypeKind.rawValue, forKey: SortTypeUserDetailsUtils.userListingSortTypeKey)
        }
    }
    
    func sensitiveContentChanged() {
        refreshUsers()
    }
    
    func toggleSelection(user: User) {
        if selectedUsers.index(id: user.id) != nil {
            selectedUsers.remove(user)
        } else if selectedSubscribedUsers.index(id: user.id) != nil {
            selectedSubscribedUsers.remove(id: user.id)
        } else if selectedUserData.index(id: user.id) != nil {
            selectedUserData.remove(id: user.id)
        } else if selectedUserSubredditsInCustomFeed.index(id: "u_\(user.name)") != nil {
            selectedUserSubredditsInCustomFeed.remove(id: "u_\(user.name)")
        } else {
            selectedUsers.append(user)
        }
    }
}
