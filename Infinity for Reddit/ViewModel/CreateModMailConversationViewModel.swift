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
    
    private let createModMailConversationRepository: CreateModMailConversationRepositoryProtocol
    
    init(createModMailConversationRepository: CreateModMailConversationRepositoryProtocol) {
        self.createModMailConversationRepository = createModMailConversationRepository
    }
}
