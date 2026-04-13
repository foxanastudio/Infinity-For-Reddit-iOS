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
    @Published var hasMorePages: Bool = true
    @Published var error: Error?
    
    private var messages: [String: ModMailMessage] = [:]
    private var conversationIds: Set<String> = []
    private var after: String? = nil
    
    public let modMailListingRepository: ModMailListingRepositoryProtocol
    
    init(modMailListingRepository: ModMailListingRepositoryProtocol) {
        self.modMailListingRepository = modMailListingRepository
    }
    
    public func initialLoadModMailListing() async {
        guard isInitialLoad else {
            return
        }
        
        await loadModMailListing()
    }
    
    public func loadModMailListing() async {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else {
            return
        }
        
        let isInitialLoadCopy = isInitialLoad

        if conversations.isEmpty {
            isInitialLoading = true
        } else {
            isLoadingMore = true
        }
        
        if isInitialLoad {
            isInitialLoad = false
        }
        
        do {
            try Task.checkCancellation()
            
            let modMailListing = try await modMailListingRepository.fetchModMailListing(
                queries: [
                    "after": after ?? "",
                    "state": "all",
                    "sort": "recent"
                ],
                interceptor: nil
            )
            
            try Task.checkCancellation()
            
            let newConversations = modMailListing.orderedConversations.filter { conversationIds.insert($0.id).inserted }
            if (newConversations.isEmpty) {
                self.hasMorePages = false
                self.after = nil
            } else {
                self.messages.merge(modMailListing.messages) { _, new in new }
                self.conversations.append(contentsOf: newConversations)
                self.after = modMailListing.after
                self.hasMorePages = !(after == nil || after?.isEmpty == true)
            }

            self.isInitialLoading = false
            self.isLoadingMore = false
        } catch {
            if !(error is CancellationError) {
                self.error = error
                printInDebugOnly("Error fetching mod mail listing: \(error)")
            }
            
            self.isInitialLoad = isInitialLoadCopy
            self.isInitialLoading = false
            self.isLoadingMore = false
        }
    }
    
    func refreshModMailListing() {
        isInitialLoad = true
        isInitialLoading = false
        isLoadingMore = false

        after = nil
        hasMorePages = true
        messages.removeAll()
        conversationIds.removeAll()
        conversations.removeAll()

        loadModMailFlag.toggle()
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
