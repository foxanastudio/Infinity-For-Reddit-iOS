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
    @Published var recepient: String?
    @Published var error: Error?
    @Published var listScrollTarget: String?
    
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
            var recepientTemp: String?
            if let inboxes = inbox.replies?.data.inboxes {
                for i in (0..<inboxes.count).reversed() {
                    if inboxes[i].author != AccountViewModel.shared.account.username {
                        fullNameTemp = inboxes[i].name
                        fullNameToReplyTo = fullNameTemp
                        recepientTemp = inboxes[i].author
                        recepient = recepientTemp
                        break
                    } else if inboxes[i].dest != AccountViewModel.shared.account.username {
                        recepientTemp = inboxes[i].dest
                        recepient = recepientTemp
                    }
                }
            }
            if fullNameTemp == nil {
                fullNameToReplyTo = inbox.name
            }
            if recepientTemp == nil {
                recepient = inbox.dest
            }
        } else {
            fullNameToReplyTo = inbox.name
            recepient = inbox.author
        }
        self.inboxConversationRepository = inboxConversationRepository
    }
    
    func sendMessage(message: String) async {
        guard let fullNameToReplyTo else { return }
        
        do {
            try Task.checkCancellation()
            
            let newInbox = try await inboxConversationRepository.sendMessage(message: message, fullNameToReplyTo: fullNameToReplyTo)
            
            await MainActor.run {
                if inbox.replies == nil {
                    inbox.replies = InboxListingRootClass(inbox: newInbox)
                } else {
                    inbox.replies?.data.inboxes = (inbox.replies?.data?.inboxes ?? []) + [newInbox]
                }
                listScrollTarget = newInbox.id
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
            
            print("Error sending message: \(error)")
        }
    }
}
