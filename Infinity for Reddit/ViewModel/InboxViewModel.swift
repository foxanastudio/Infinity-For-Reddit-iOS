//
//  InboxViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-16.
//

import Foundation

class InboxViewModel: ObservableObject {
    private let inboxRepository: InboxRepositoryProtocol
    
    init(inboxRepository: InboxRepositoryProtocol) {
        self.inboxRepository = inboxRepository
    }
    
    func readAllMessages() async {
        await inboxRepository.readAllMessages()
    }
}
