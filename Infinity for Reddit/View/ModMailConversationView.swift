//
//  ModMailConversationView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-14.
//

import SwiftUI

struct ModMailConversationView: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    
    @StateObject var modMailConversationViewModel: ModMailConversationViewModel
    
    let participantUsername: String
    
    init(
        conversationId: String,
        participantUsername: String
    ) {
        self.participantUsername = participantUsername
        _modMailConversationViewModel = StateObject(
            wrappedValue: ModMailConversationViewModel(
                conversationId: conversationId,
                modMailConversationRepository: ModMailConversationRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            List {
                let messages = modMailConversationViewModel.modMailConversationDetail?.orderedMessages.reversed() ?? []
                
                ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                    let isLastFromSender = index == 0 || messages[index - 1].author.name != message.author.name
                    
                    ChatBubble(isSentMessage: message.author.name == accountViewModel.account.username, shouldShowTail: isLastFromSender) {
                        Text(message.displayBody)
                    }
                    .listPlainItemNoInsets()
                    .rotationEffect(.degrees(180))
                    .id(message.id)
                }
            }
            .rotationEffect(.degrees(180))
            .themedList()
            .scrollIndicators(.hidden)
        }
        .task {
            await modMailConversationViewModel.initialLoadModMailConversation()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar(participantUsername)
        .showErrorUsingSnackbar(modMailConversationViewModel.$error)
    }
}
