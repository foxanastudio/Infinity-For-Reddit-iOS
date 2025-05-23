//
//  UserListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-22.
//

import Foundation

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
    
    private var after: String? = nil
    
    public let userListingRepository: UserListingRepositoryProtocol
    
    // MARK: - Initializer
    init(query: String, userListingRepository: UserListingRepositoryProtocol) {
        self.query = query
        self.userListingRepository = userListingRepository
    }
    
    // MARK: - Methods
    
    public func initialLoadUsers() async {
        guard isInitialLoad else {
            return
        }
        
        await loadUsers()
    }
    
    public func loadUsers() async {
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
            
            let userListing = try await userListingRepository.fetchUserListing(queries: ["q": query, "type": "user", "limit": "100", "after": after ?? ""])
            
            try Task.checkCancellation()
            
            if (userListing.users.isEmpty) {
                // No more users
                hasMorePages = false
                self.after = nil
            } else {
                
                self.after = userListing.after
                
                self.users.append(contentsOf: userListing.users)
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
            
            print("Error fetching users: \(error)")
        }
    }
    
    func refreshUsers() async {
        await MainActor.run {
            isInitialLoad = true
            isInitialLoading = false
            isLoadingMore = false
            
            after = nil
            hasMorePages = true
            users = []
        }
        
        await initialLoadUsers()
    }
}
