//
//  InboxViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-23.
//

import Foundation

@MainActor
public class InboxListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var messageWhere: MessageWhere
    @Published var inboxes: [Inbox] = []
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    @Published var error: Error?
    
    private var after: String? = nil
    
    public let inboxListingRepository: InboxListingRepositoryProtocol
    
    // MARK: - Initializer
    init(messageWhere: MessageWhere, inboxListingRepository: InboxListingRepositoryProtocol) {
        self.messageWhere = messageWhere
        self.inboxListingRepository = inboxListingRepository
    }
    
    // MARK: - Methods
    
    public func initialLoadInboxes() async {
        guard isInitialLoad else {
            return
        }
        
        await loadInboxes()
    }
    
    public func loadInboxes() async {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else { return }
        
        let isInitailLoadCopy = isInitialLoad
        
        if inboxes.isEmpty {
            isInitialLoading = true
        } else {
            isLoadingMore = true
        }
        
        if isInitialLoad {
            isInitialLoad = false
        }
        
        do {
            try Task.checkCancellation()
            
            let inboxListing = try await inboxListingRepository.fetchInboxListing(messageWhere: messageWhere, pathComponents: ["where": messageWhere.rawValue], queries: ["after": after ?? ""])
            
            try Task.checkCancellation()
            
            if (inboxListing.inboxes.isEmpty) {
                // No more inboxes
                hasMorePages = false
                self.after = nil
            } else {
                
                self.after = inboxListing.after
                
                self.inboxes.append(contentsOf: inboxListing.inboxes)
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
            
            print("Error fetching inboxes: \(error)")
        }
    }
    
    func refreshInboxes() async {
        await MainActor.run {
            isInitialLoad = true
            isInitialLoading = false
            isLoadingMore = false
            
            after = nil
            hasMorePages = true
            inboxes = []
        }
        
        await initialLoadInboxes()
    }
}
