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
    @Published var loadInboxFlag: Bool = false
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    @Published var error: Error?
    
    private var after: String? = nil
    
    public let inboxListingRepository: InboxListingRepositoryProtocol
    
    init(messageWhere: MessageWhere, inboxListingRepository: InboxListingRepositoryProtocol) {
        self.messageWhere = messageWhere
        self.inboxListingRepository = inboxListingRepository
    }
    
    public func initialLoadInboxes() async {
        guard isInitialLoad else {
            return
        }
        
        await loadInboxes()
    }
    
    public func loadInboxes() async {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else { return }
        
        let isInitialLoadCopy = isInitialLoad
        
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
            
            let inboxListing = try await inboxListingRepository.fetchInboxListing(
                messageWhere: messageWhere,
                pathComponents: ["where": messageWhere.rawValue],
                queries: ["after": after ?? ""],
                interceptor: nil
            )
            
            try Task.checkCancellation()
            
            if (inboxListing.inboxes.isEmpty) {
                self.hasMorePages = false
                self.after = nil
            } else {
                self.inboxes.append(contentsOf: inboxListing.inboxes)
                self.after = inboxListing.after
                self.hasMorePages = !(after == nil || after?.isEmpty == true)
            }
            
            self.isInitialLoading = false
            self.isLoadingMore = false
        } catch {
            if !(error is CancellationError) {
                self.error = error
                printInDebugOnly("Error fetching inboxes: \(error)")
            }
            
            self.isInitialLoad = isInitialLoadCopy
            self.isInitialLoading = false
            self.isLoadingMore = false
        }
    }
    
    func refreshInboxes() {
        isInitialLoad = true
        isInitialLoading = false
        isLoadingMore = false
        
        after = nil
        hasMorePages = true
        inboxes.removeAll()
        
        loadInboxFlag.toggle()
    }
    
    func markAsRead(inbox: Inbox) {
        guard inbox.isNew else {
            return
        }
        inbox.isNew = false
        
        Task {
            try? await inboxListingRepository.markAsRead(inbox: inbox, interceptor: nil)
        }
    }
}
