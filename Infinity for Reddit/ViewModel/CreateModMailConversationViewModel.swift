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
    @Published var subject: String = "" {
        didSet {
            if subject.count > subjectCharacterLimit {
                subject = String(subject.prefix(subjectCharacterLimit))
            }
        }
    }
    @Published var content: String = ""
    
    let subjectCharacterLimit = 100
    
    private let createModMailConversationRepository: CreateModMailConversationRepositoryProtocol
    
    init(createModMailConversationRepository: CreateModMailConversationRepositoryProtocol) {
        self.createModMailConversationRepository = createModMailConversationRepository
    }
}
