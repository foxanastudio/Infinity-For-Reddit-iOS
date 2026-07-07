//
//  ModMailConversationViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-15.
//

import Foundation

@MainActor
class ModMailConversationViewModel: ObservableObject {
    @Published var conversation: ModMailConversation
    @Published var modMailConversationDetail: ModMailConversationDetail?
    @Published var isLoading: Bool = false
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var error: Error?
    @Published var listScrollTarget: String?

    private let modMailConversationRepository: ModMailConversationRepositoryProtocol
    
    init(
        conversation: ModMailConversation,
        modMailConversationRepository: ModMailConversationRepositoryProtocol
    ) {
        self.conversation = conversation
        self.modMailConversationRepository = modMailConversationRepository
    }

    var participantUsername: String {
        conversation.participant.name
    }

    private var conversationId: String {
        conversation.id
    }
    
    func messages(currentUsername: String) -> [ModMailConversationDisplayMessage] {
        let modMailMessages = modMailConversationDetail?.orderedMessages.reversed() ?? []
        
        return Array(modMailMessages.enumerated()).map { modMailMessageIndex, modMailMessage in
            displayMessage(
                modMailMessage: modMailMessage,
                modMailMessageIndex: modMailMessageIndex,
                modMailMessages: modMailMessages,
                currentUsername: currentUsername
            )
        }
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
        
        if modMailConversationDetail == nil {
            isInitialLoading = true
        }

        if isInitialLoad {
            isInitialLoad = false
        }
        
        error = nil

        do {
            try Task.checkCancellation()

            let modMailConversationDetail = try await modMailConversationRepository.fetchModMailConversation(
                conversationId: conversationId,
                interceptor: nil
            )

            try Task.checkCancellation()

            self.modMailConversationDetail = modMailConversationDetail
            self.isLoading = false
            self.isInitialLoading = false
            self.conversation = modMailConversationDetail.conversation
        } catch {
            if !(error is CancellationError) {
                self.error = error
                printInDebugOnly("Cannot fetch mod mail conversation: \(error)")
            }
            self.isInitialLoad = isInitialLoadCopy

            self.isLoading = false
            self.isInitialLoading = false
        }
    }
    
    func sendMessage(message: String, authorName: String, isAuthorHidden: Bool, isInternal: Bool) async -> ModMailConversationDetail? {
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
            let messageToScrollTo = shouldAppendMessage ? modMailConversationDetail.appendMessage(
                body: message,
                authorName: authorName,
                isInternal: isInternal,
                isAuthorHidden: isAuthorHidden
            )
            : latestMessage

            modMailConversationDetail.refreshConversationMetadata()

            self.modMailConversationDetail = modMailConversationDetail
            self.conversation = modMailConversationDetail.conversation
            
            Task { @MainActor in
                await Task.yield()
                self.listScrollTarget = messageToScrollTo?.id
            }
            
            return modMailConversationDetail
        } catch {
            self.error = error
            
            printInDebugOnly("Error sending message: \(error)")
            
            return nil
        }
    }
    
    private func displayMessage(
        modMailMessage: ModMailMessage,
        modMailMessageIndex: Int,
        modMailMessages: [ModMailMessage],
        currentUsername: String
    ) -> ModMailConversationDisplayMessage {
        let isSentMessage = isSentModMailMessage(modMailMessage, currentUsername: currentUsername)
        let modMailSenderLabelContent = modMailSenderLabelContent(
            modMailMessage: modMailMessage,
            isSentMessage: isSentMessage,
            currentUsername: currentUsername
        )
        let modMailSenderLabel = shouldShowModMailSenderLabel(
            modMailMessage: modMailMessage,
            modMailMessageIndex: modMailMessageIndex,
            modMailMessages: modMailMessages,
            currentIsSentMessage: isSentMessage,
            currentLabel: modMailSenderLabelContent,
            currentUsername: currentUsername
        ) ? modMailSenderLabelContent : nil
        
        return ModMailConversationDisplayMessage(
            message: modMailMessage,
            isSentMessage: isSentMessage,
            modMailSenderLabel: modMailSenderLabel
        )
    }
    
    private func isSentModMailMessage(_ message: ModMailMessage, currentUsername: String) -> Bool {
        let authorName = message.author.name
        let subredditName = conversation.owner.displayName ?? ""
        return authorName == currentUsername || authorName == subredditName
    }
    
    private func modMailSenderLabelContent(
        modMailMessage: ModMailMessage,
        isSentMessage: Bool,
        currentUsername: String
    ) -> String? {
        let subredditName = conversation.owner.displayName ?? ""

        guard isSentMessage else {
            let authorName = modMailMessage.author.name ?? ""
            if !authorName.isEmpty {
                return "u/\(authorName)"
            }

            if !participantUsername.isEmpty {
                return "u/\(participantUsername)"
            }

            return nil
        }

        if modMailMessage.isInternal {
            return "Mods only"
        }

        if modMailMessage.author.isHidden == true {
            guard !subredditName.isEmpty else {
                return nil
            }
            return "r/\(subredditName)"
        }

        return "u/\(currentUsername)"
    }
    
    private func shouldShowModMailSenderLabel(
        modMailMessage: ModMailMessage,
        modMailMessageIndex: Int,
        modMailMessages: [ModMailMessage],
        currentIsSentMessage: Bool,
        currentLabel: String?,
        currentUsername: String
    ) -> Bool {
        guard let currentLabel else {
            return false
        }
        
        let visuallyPreviousModMailMessageIndex = modMailMessageIndex + 1
        guard modMailMessages.indices.contains(visuallyPreviousModMailMessageIndex) else {
            return true
        }
        
        let previousModMailMessage = modMailMessages[visuallyPreviousModMailMessageIndex]
        let previousIsSentMessage = isSentModMailMessage(previousModMailMessage, currentUsername: currentUsername)
        
        if previousIsSentMessage != currentIsSentMessage {
            return true
        }
        
        let previousLabel = modMailSenderLabelContent(
            modMailMessage: previousModMailMessage,
            isSentMessage: previousIsSentMessage,
            currentUsername: currentUsername
        )
        
        return currentLabel != previousLabel
    }
    
    
    func reloadModMailConversation() {
        error = nil
        isInitialLoad = true
        isInitialLoading = false
        modMailConversationDetail = nil

        Task {
            await loadModMailConversation()
        }
    }
    
    struct ModMailConversationDisplayMessage: Identifiable {
        let message: ModMailMessage
        let isSentMessage: Bool
        let modMailSenderLabel: String?
        
        var id: String {
            message.id
        }
    }
}
