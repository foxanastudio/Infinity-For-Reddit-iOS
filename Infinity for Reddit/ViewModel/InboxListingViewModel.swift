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
    @Published var error: Error?
    
    private var after: String? = nil
    
    var hasMorePages: Bool {
        isInitialLoad || !(after == nil || after?.isEmpty == true)
    }
    
    private var refreshInboxesContinuation: CheckedContinuation<Void, Never>?
    
    var isPullToRefreshing: Bool {
        refreshInboxesContinuation != nil
    }
    
    public let inboxListingRepository: InboxListingRepositoryProtocol
    
    init(messageWhere: MessageWhere, inboxListingRepository: InboxListingRepositoryProtocol) {
        self.messageWhere = messageWhere
        self.inboxListingRepository = inboxListingRepository
    }
    
    public func initialLoadInboxes() async {
        guard isInitialLoad else {
            return
        }
        
        await loadInboxes(isRefreshWithContinuation: refreshInboxesContinuation != nil)
    }
    
    public func loadInboxes(isRefreshWithContinuation: Bool = false) async {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else { return }
        
        let isInitialLoadCopy = isInitialLoad
        
        if inboxes.isEmpty || isRefreshWithContinuation {
            isInitialLoading = true
        } else {
            isLoadingMore = true
        }
        
        if isInitialLoad {
            isInitialLoad = false
        }
        
        self.error = nil
        
        do {
            try Task.checkCancellation()
            
            let inboxListing = try await inboxListingRepository.fetchInboxListing(
                messageWhere: messageWhere,
                pathComponents: ["where": messageWhere.rawValue],
                queries: ["after": isRefreshWithContinuation ? "" : (after ?? "")],
                interceptor: nil
            )
            
            try Task.checkCancellation()
            
            if (inboxListing.inboxes.isEmpty) {
                self.after = nil
            } else {
                if isRefreshWithContinuation {
                    self.inboxes.removeAll()
                }
                self.inboxes.append(contentsOf: inboxListing.inboxes)
                self.after = inboxListing.after
            }
            
            if isRefreshWithContinuation {
                finishPullToRefresh()
            }
            
            self.isInitialLoading = false
            self.isLoadingMore = false
        } catch {
            if !(error is CancellationError) {
                self.error = error
                printInDebugOnly("Error fetching inboxes: \(error)")
            }
            
            if isRefreshWithContinuation {
                finishPullToRefresh()
            } else {
                self.isInitialLoad = isInitialLoadCopy
            }
            
            self.isInitialLoading = false
            self.isLoadingMore = false
        }
    }
    
    func refreshInboxesWithContinuation() async {
        await withCheckedContinuation { continuation in
            refreshInboxesContinuation = continuation
            refreshInboxes()
        }
    }
    
    func refreshInboxes() {
        isInitialLoad = true
        isInitialLoading = false
        isLoadingMore = false

        if refreshInboxesContinuation == nil {
            after = nil
            inboxes.removeAll()
        }
        
        loadInboxFlag.toggle()
    }
    
    func finishPullToRefresh() {
        refreshInboxesContinuation?.resume()
        refreshInboxesContinuation = nil
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
