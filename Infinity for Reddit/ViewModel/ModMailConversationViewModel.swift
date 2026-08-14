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
    @Published var modMailConversationDisplayMessages: [ModMailConversationDisplayMessage]?
    @Published var loadConversationFlag: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var sendMessageError: Error?
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

    func loadModMailConversation() async {
        isLoading = true
        error = nil

        do {
            try Task.checkCancellation()

            let modMailConversationDetail = try await modMailConversationRepository.fetchModMailConversation(
                conversationId: conversation.id
            )

            try Task.checkCancellation()

            self.modMailConversationDetail = modMailConversationDetail
            extractMessages()
            self.conversation = modMailConversationDetail.conversation
        } catch {
            if !(error is CancellationError) {
                self.error = error
                printInDebugOnly("Cannot fetch mod mail conversation: \(error)")
            }
        }
        self.isLoading = false
    }
    
    func sendMessage(message: String, authorName: String, isAuthorHidden: Bool, isInternal: Bool) async -> ModMailConversationDetail? {
        sendMessageError = nil
        do {
            let previousMessageCount = modMailConversationDetail?.orderedMessages.count ?? 0
            let modMailConversationDetail = try await modMailConversationRepository.sendMessage(
                message: message,
                conversationId: conversation.id,
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
            ) : latestMessage

            modMailConversationDetail.refreshConversationMetadata()

            self.modMailConversationDetail = modMailConversationDetail
            self.conversation = modMailConversationDetail.conversation
            extractMessages()
            
            Task { @MainActor in
                await Task.yield()
                self.listScrollTarget = messageToScrollTo?.id
            }
            
            return modMailConversationDetail
        } catch {
            self.sendMessageError = error
            
            printInDebugOnly("Error sending message: \(error)")
            
            return nil
        }
    }
    
    private func extractMessages() {
        guard let modMailConversationDetail else {
            modMailConversationDisplayMessages = nil
            return
        }
        
        let modMailMessages = Array(modMailConversationDetail.orderedMessages.reversed())
        
        modMailConversationDisplayMessages = Array(modMailMessages.enumerated()).map { modMailMessageIndex, modMailMessage in
            let isSentMessage = isSentModMailMessage(modMailMessage)
            let modMailSenderLabelContent = getModMailSenderLabelContent(
                modMailMessage: modMailMessage,
                isSentMessage: isSentMessage
            )
            let modMailSenderLabel = shouldShowModMailSenderLabel(
                modMailMessage: modMailMessage,
                modMailMessageIndex: modMailMessageIndex,
                modMailMessages: modMailMessages,
                currentIsSentMessage: isSentMessage,
                currentLabel: modMailSenderLabelContent
            ) ? modMailSenderLabelContent : nil
            
            return ModMailConversationDisplayMessage(
                message: modMailMessage,
                isSentMessage: isSentMessage,
                modMailSenderLabel: modMailSenderLabel,
                isInternal: modMailMessage.isInternal
            )
        }
    }
    
    private func getDisplayMessage(
        modMailMessage: ModMailMessage,
        modMailMessageIndex: Int,
        modMailMessages: [ModMailMessage]
    ) -> ModMailConversationDisplayMessage {
        let isSentMessage = isSentModMailMessage(modMailMessage)
        let modMailSenderLabelContent = getModMailSenderLabelContent(
            modMailMessage: modMailMessage,
            isSentMessage: isSentMessage
        )
        let modMailSenderLabel = shouldShowModMailSenderLabel(
            modMailMessage: modMailMessage,
            modMailMessageIndex: modMailMessageIndex,
            modMailMessages: modMailMessages,
            currentIsSentMessage: isSentMessage,
            currentLabel: modMailSenderLabelContent
        ) ? modMailSenderLabelContent : nil
        
        return ModMailConversationDisplayMessage(
            message: modMailMessage,
            isSentMessage: isSentMessage,
            modMailSenderLabel: modMailSenderLabel,
            isInternal: modMailMessage.isInternal
        )
    }
    
    private func isSentModMailMessage(_ message: ModMailMessage) -> Bool {
        let authorName = message.author.name
        let subredditName = conversation.owner.displayName ?? ""
        return authorName == AccountViewModel.shared.account.username || authorName == subredditName
    }
    
    private func getModMailSenderLabelContent(
        modMailMessage: ModMailMessage,
        isSentMessage: Bool
    ) -> String? {
        let subredditName = conversation.owner.displayName ?? ""

        guard isSentMessage else {
            if let authorName = modMailMessage.author.name, !authorName.isEmpty {
                return "u/\(authorName)"
            }

            if !participantUsername.isEmpty {
                return "u/\(participantUsername)"
            }

            return nil
        }

        if modMailMessage.author.isHidden == true {
            guard !subredditName.isEmpty else {
                return nil
            }
            return "r/\(subredditName)"
        }

        return "u/\(AccountViewModel.shared.account.username)"
    }
    
    private func shouldShowModMailSenderLabel(
        modMailMessage: ModMailMessage,
        modMailMessageIndex: Int,
        modMailMessages: [ModMailMessage],
        currentIsSentMessage: Bool,
        currentLabel: String?
    ) -> Bool {
        guard let currentLabel else {
            return false
        }
        
        let visuallyPreviousModMailMessageIndex = modMailMessageIndex + 1
        guard modMailMessages.indices.contains(visuallyPreviousModMailMessageIndex) else {
            return true
        }
        
        let previousModMailMessage = modMailMessages[visuallyPreviousModMailMessageIndex]
        let previousIsSentMessage = isSentModMailMessage(previousModMailMessage)
        
        if previousIsSentMessage != currentIsSentMessage {
            return true
        }
        
        let previousLabel = getModMailSenderLabelContent(
            modMailMessage: previousModMailMessage,
            isSentMessage: previousIsSentMessage
        )
        
        return currentLabel != previousLabel
    }
    
    
    func refreshModMailConversation() {
        error = nil
        sendMessageError = nil
        isLoading = false
        modMailConversationDetail = nil
        modMailConversationDisplayMessages = nil
        loadConversationFlag.toggle()
    }
    
    struct ModMailConversationDisplayMessage: Identifiable {
        let message: ModMailMessage
        let isSentMessage: Bool
        let modMailSenderLabel: String?
        let isInternal: Bool

        var id: String {
            message.id
        }
    }
}
