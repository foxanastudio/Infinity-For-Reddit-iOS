//
//  ModMailListingViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-09.
//

import Foundation

@MainActor
public class ModMailListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var conversations: [ModMailConversation] = []
    @Published var loadModMailFlag: Bool = false
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var error: Error?
    
    private var messages: [String: ModMailMessage] = [:]
    private var conversationIds: Set<String> = []
    private var after: String? = nil
    private var refreshModMailListingContinuation: CheckedContinuation<Void, Never>?
    
    public let modMailListingRepository: ModMailListingRepositoryProtocol
    
    var hasMorePages: Bool {
        isInitialLoad || !(after == nil || after?.isEmpty == true)
    }
    
    var isPullToRefreshing: Bool {
        refreshModMailListingContinuation != nil
    }
    
    init(modMailListingRepository: ModMailListingRepositoryProtocol) {
        self.modMailListingRepository = modMailListingRepository
    }
    
    public func initialLoadModMailListing() async {
        guard isInitialLoad else {
            return
        }
        
        await loadModMailListing(isRefreshWithContinuation: refreshModMailListingContinuation != nil)
    }
    
    public func loadModMailListing(isRefreshWithContinuation: Bool = false) async {
        guard !isInitialLoading, !isLoadingMore, isRefreshWithContinuation || hasMorePages else {
            return
        }
        
        let isInitialLoadCopy = isInitialLoad

        if conversations.isEmpty || isRefreshWithContinuation {
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
            
            let modMailListing = try await modMailListingRepository.fetchModMailListing(
                queries: [
                    "after": isRefreshWithContinuation ? "" : (after ?? ""),
                    "state": "all",
                    "sort": "recent"
                ],
                interceptor: nil
            )
            
            try Task.checkCancellation()
            
            let existingConversationIds = isRefreshWithContinuation ? Set<String>() : conversationIds
            let newConversations = modMailListing.orderedConversations.filter { !existingConversationIds.contains($0.id) }
            if (newConversations.isEmpty) {
                self.after = nil
            } else {
                if isRefreshWithContinuation {
                    self.messages.removeAll()
                    self.conversationIds.removeAll()
                    self.conversations.removeAll()
                }
                self.messages.merge(modMailListing.messages) { _, new in new }
                self.conversationIds.formUnion(newConversations.map(\.id))
                self.conversations.append(contentsOf: newConversations)
                self.after = modMailListing.after
            }
            
            if isRefreshWithContinuation {
                finishPullToRefresh()
            }

            self.isInitialLoading = false
            self.isLoadingMore = false
        } catch {
            if !(error is CancellationError) {
                self.error = error
                printInDebugOnly("Error fetching mod mail listing: \(error)")
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
    
    func refreshModMailListingWithContinuation() async {
        await withCheckedContinuation { continuation in
            refreshModMailListingContinuation = continuation
            refreshModMailListing()
        }
    }
    
    func refreshModMailListing() {
        isInitialLoad = true
        isInitialLoading = false
        isLoadingMore = false

        if refreshModMailListingContinuation == nil {
            after = nil
            messages.removeAll()
            conversationIds.removeAll()
            conversations.removeAll()
        }

        loadModMailFlag.toggle()
    }
    
    func finishPullToRefresh() {
        refreshModMailListingContinuation?.resume()
        refreshModMailListingContinuation = nil
    }
    
    func markAsRead(conversation: ModMailConversation) {
        guard conversation.isUnread else {
            return
        }
        conversation.lastUnread = nil
    }
    
    func latestMessagePreview(for conversation: ModMailConversation) -> String {
        for objectId in conversation.objIds.reversed() {
            guard objectId.key == "messages", let message = messages[objectId.id] else {
                continue
            }

            let bodyMarkdown = message.bodyMarkdown.trimmingCharacters(in: .whitespacesAndNewlines)
            if !bodyMarkdown.isEmpty {
                return bodyMarkdown
            }

            return message.body.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return ""
    }
}
