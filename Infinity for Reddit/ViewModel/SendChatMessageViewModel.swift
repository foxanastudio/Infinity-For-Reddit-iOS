//
//  SendChatMessageViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import Foundation

@MainActor
class SendChatMessageViewModel: ObservableObject {
    @Published var recipient: String
    @Published var subject: String = ""
    @Published var message: String = ""
    @Published var sendChatMessageTask: Task<Void, Never>?
    @Published var chatMessageSentFlag: Bool = false
    @Published var error: Error? = nil
    
    private let sendChatMessageRepository: SendChatMessageRepositoryProtocol
    
    init(recipient: String?, sendChatMessageRepository: SendChatMessageRepositoryProtocol) {
        self.recipient = recipient ?? ""
        self.sendChatMessageRepository = sendChatMessageRepository
    }
    
    func sendChatMessage() {
        guard sendChatMessageTask == nil else {
            return
        }
        
        chatMessageSentFlag = false
        sendChatMessageTask = Task {
            do {
                try await self.sendChatMessageRepository.sendChatMessage(
                    recipient: self.recipient,
                    subject: self.subject,
                    message: self.message
                )
                
                self.chatMessageSentFlag = true
            } catch {
                self.error = error
            }
            
            self.sendChatMessageTask = nil
        }
    }
}
