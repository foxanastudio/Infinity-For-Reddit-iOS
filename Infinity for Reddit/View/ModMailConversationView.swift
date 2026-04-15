//
//  ModMailConversationView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-14.
//

import SwiftUI

struct ModMailConversationView: View {
    let conversationId: String
    let participantUsername: String
    private let modMailConversationRepository: ModMailConversationRepositoryProtocol

    @State private var isLoading: Bool = false
    
    init(
        conversationId: String,
        participantUsername: String,
        modMailConversationRepository: ModMailConversationRepositoryProtocol = ModMailConversationRepository()
    ) {
        self.conversationId = conversationId
        self.participantUsername = participantUsername
        self.modMailConversationRepository = modMailConversationRepository
    }

    var body: some View {
        RootView {
            Text("ModMailConversationView")
        }
        .task {
            await loadModMailConversation()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar(participantUsername)
    }
    
    private func loadModMailConversation() async {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        
        do {
            let modMailConversationResponse = try await modMailConversationRepository.fetchModMailConversation(
                conversationId: conversationId,
                interceptor: nil
            )
            printInDebugOnly(modMailConversationResponse)
            isLoading = false
        } catch {
            if !(error is CancellationError) {
                printInDebugOnly("Cannot fetch mod mail conversation.")
            }
            
            isLoading = false
        }
    }
}
