//
//  CreateModMailConversationViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-07.
//

import Foundation

@MainActor
class CreateModMailConversationViewModel: ObservableObject {
    @Published var recipientType: ModMailRecipientType = .moderators {
        didSet {
            if oldValue != recipientType {
                recipient = ""
            }
        }
    }
    @Published var recipient: String = ""
    @Published var isAuthorHidden: Bool = true
    @Published var selectedSubreddit: ModeratedSubreddit?
    @Published var subject: String = ""
    @Published var content: String = ""
    @Published var createConversationTask: Task<Void, Never>?
    @Published var createdConversationDetail: ModMailConversationDetail?
    @Published var error: Error? = nil
    
    private let createModMailConversationRepository: CreateModMailConversationRepositoryProtocol
    
    init(createModMailConversationRepository: CreateModMailConversationRepositoryProtocol) {
        self.createModMailConversationRepository = createModMailConversationRepository
    }
    
    func createConversation() {
        guard createConversationTask == nil else {
            return
        }
        
        guard let selectedSubreddit else {
            error = ModMailCreationError.subredditNotSelectedError
            return
        }
        
        let recipientName = getRecipientName()
        guard recipientType == .moderators || !recipientName.isEmpty else {
            error = ModMailCreationError.noRecipientError
            return
        }
        
        guard !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = ModMailCreationError.noSubjectError
            return
        }
        
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = ModMailCreationError.noMessageError
            return
        }
        
        let to: String?
        switch recipientType {
        case .moderators:
            to = nil
        case .user:
            to = recipientName
        case .community:
            to = "r/\(recipientName)"
        }
        
        createdConversationDetail = nil
        
        createConversationTask = Task {
            do {
                createdConversationDetail = try await createModMailConversationRepository.createConversation(
                    subredditName: selectedSubreddit.name,
                    subject: subject,
                    body: content,
                    to: to,
                    isAuthorHidden: recipientType == .user && isAuthorHidden
                )
            } catch {
                self.error = error
                printInDebugOnly(error)
            }
            
            self.createConversationTask = nil
        }
    }
    
    private func getRecipientName() -> String {
        let recipientName = recipient.trimmingCharacters(in: .whitespacesAndNewlines)
        for prefix in ["/u/", "/r/", "u/", "r/"] where recipientName.lowercased().hasPrefix(prefix) {
            return String(recipientName.dropFirst(prefix.count))
        }
        return recipientName
    }
}
