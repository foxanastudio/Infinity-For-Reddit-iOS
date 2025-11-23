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
    @Published var hasMorePages: Bool = true
    @Published var error: Error?
    @Published var sortType: SortType.Kind
    @Published var loadUsersTaskId = UUID()
    
    @Published var selectedUsers: IdentifiedArrayOf<User> = []
    
    private var after: String? = nil
    private var lastLoadedSortType: SortType.Kind? = nil
    
    // UserDefaults
    private var sensitiveContent: Bool
    
    let thingSelectionMode: ThingSelectionMode
    
    public let userListingRepository: UserListingRepositoryProtocol
    
    private var refreshUsersContinuation: CheckedContinuation<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(query: String, thingSelectionMode: ThingSelectionMode, userListingRepository: UserListingRepositoryProtocol) {
        self.query = query
        self.thingSelectionMode = thingSelectionMode
        self.sortType = SortTypeUserDetailsUtils.userListing
        self.userListingRepository = userListingRepository
        
        self.sensitiveContent = ContentSensitivityFilterUserDetailsUtils.sensitiveContent
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                let sensitiveContent = UserDefaults.contentSensitivityFilter.bool(forKey: ContentSensitivityFilterUserDetailsUtils.sensitiveContentKey)
                self?.setSensitiveContent(sensitiveContent)
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
        
        let isInitailLoadCopy = isInitialLoad
        
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
                queries: ["q": query, "type": "user", "sort": sortType.rawValue, "limit": "100", "after": after ?? "", "include_over_18": sensitiveContent ? "1" : "0"]
            )
            
            try Task.checkCancellation()
            
            if (userListing.users.isEmpty) {
                // No more users
                self.hasMorePages = false
                self.after = nil
            } else {
                self.after = userListing.after
                if isRefreshWithContinuation {
                    self.users.removeAll()
                }
                self.users.append(contentsOf: userListing.users)
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
            
            print("Error fetching users: \(error)")
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
        
        after = nil
        hasMorePages = true
        if refreshUsersContinuation == nil {
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
    
    func setSensitiveContent(_ sensitiveContent: Bool) {
        if sensitiveContent != self.sensitiveContent {
            self.sensitiveContent = sensitiveContent
            refreshUsers()
        }
    }
    
    func toggleSelection(user: User) {
        if selectedUsers.index(id: user.id) != nil {
            selectedUsers.remove(user)
        } else {
            selectedUsers.append(user)
        }
    }
}
