//
//  ModMailConversationViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-15.
//

import Foundation

@MainActor
class ModMailConversationViewModel: ObservableObject {
    @Published var modMailConversationDetail: ModMailConversationDetail?
    @Published var isLoading: Bool = false
    @Published var isInitialLoad: Bool = true
    @Published var error: Error?
    @Published var listScrollTarget: String?

    private let conversationId: String
    private let modMailConversationRepository: ModMailConversationRepositoryProtocol
    
    init(conversationId: String, modMailConversationRepository: ModMailConversationRepositoryProtocol) {
        self.conversationId = conversationId
        self.modMailConversationRepository = modMailConversationRepository
    }

    func initialLoadModMailConversation() async {
        guard isInitialLoad else {
            return
        }

        await loadModMailConversation()
    }

    func loadModMailConversation() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        let isInitialLoadCopy = isInitialLoad

        if isInitialLoad {
            isInitialLoad = false
        }

        do {
            try Task.checkCancellation()

            let modMailConversationDetail = try await modMailConversationRepository.fetchModMailConversation(
                conversationId: conversationId,
                interceptor: nil
            )

            try Task.checkCancellation()

            self.modMailConversationDetail = modMailConversationDetail
            self.isLoading = false
        } catch {
            if !(error is CancellationError) {
                self.error = error
                printInDebugOnly("Cannot fetch mod mail conversation: \(error)")
            }
            self.isInitialLoad = isInitialLoadCopy

            self.isLoading = false
        }
    }
    
    func sendMessage(message: String, authorName: String, isAuthorHidden: Bool, isInternal: Bool) async {
        do {
            let previousMessageCount = modMailConversationDetail?.orderedMessages.count ?? 0
            let modMailConversationDetail = try await modMailConversationRepository.sendMessage(
                message: message,
                conversationId: conversationId,
                isAuthorHidden: isAuthorHidden,
                isInternal: isInternal
            )

            let sentMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
            let latestMessage = modMailConversationDetail.orderedMessages.last
            let latestBody = latestMessage?.displayBody.trimmingCharacters(in: .whitespacesAndNewlines)
            let shouldAppendMessage = modMailConversationDetail.orderedMessages.count <= previousMessageCount || latestBody != sentMessage
            let messageToScrollTo = shouldAppendMessage
                ? modMailConversationDetail.appendMessage(body: message, isInternal: isInternal, authorName: authorName)
                : latestMessage

            self.modMailConversationDetail = modMailConversationDetail
            
            Task { @MainActor in
                await Task.yield()
                self.listScrollTarget = messageToScrollTo?.id
            }
        } catch {
            self.error = error
            
            printInDebugOnly("Error sending message: \(error)")
        }
    }
}
