//
//  InboxConversationViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-21.
//

import Foundation

class InboxConversationViewModel: ObservableObject {
    @Published var inbox: Inbox
    @Published var fullNameToReplyTo: String?
    @Published var error: Error?
    
    var conversations: [Inbox] {
        if let replies = inbox.replies?.data?.inboxes {
            return ([inbox] + replies).reversed()
        }
        
        return [inbox]
    }
    
    private let inboxConversationRepository: InboxConversationRepositoryProtocol
    
    init(inbox: Inbox, inboxConversationRepository: InboxConversationRepositoryProtocol) {
        self.inbox = inbox
        if inbox.author == AccountViewModel.shared.account.username {
            var fullNameTemp: String?
            if let inboxes = inbox.replies.data.inboxes {
                for i in (0..<inboxes.count).reversed() {
                    if inboxes[i].author != AccountViewModel.shared.account.username {
                        fullNameTemp = inboxes[i].name
                        fullNameToReplyTo = fullNameTemp
                        break
                    }
                }
            }
            if fullNameTemp == nil {
                fullNameToReplyTo = inbox.name
            }
        } else {
            fullNameToReplyTo = inbox.name
        }
        self.inboxConversationRepository = inboxConversationRepository
    }
    
    func sendMessage(message: String) async {
        guard let fullNameToReplyTo else { return }
        
        do {
            try Task.checkCancellation()
            
            let newInbox = try await inboxConversationRepository.sendMessage(message: message, fullNameToReplyTo: fullNameToReplyTo)
        } catch {
            await MainActor.run {
                self.error = error
            }
            
            print("Error sending message: \(error)")
        }
    }
}
