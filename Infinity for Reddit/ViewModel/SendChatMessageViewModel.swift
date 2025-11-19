//
//  SendChatMessageViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import Foundation

@MainActor
class SendChatMessageViewModel: ObservableObject {
    @Published var username: String
    @Published var subject: String = ""
    @Published var message: String = ""
    @Published var sendChatMessageTask: Task<Void, Never>?
    @Published var chatMessageSentFlag: Bool = false
    @Published var error: Error? = nil
    
    private let sendChatMessageRepository: SendChatMessageRepositoryProtocol
    
    init(username: String?, sendChatMessageRepository: SendChatMessageRepositoryProtocol) {
        self.username = username ?? ""
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
                    username: self.username,
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
