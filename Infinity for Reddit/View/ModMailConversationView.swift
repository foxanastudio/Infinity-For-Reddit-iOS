//
//  ModMailConversationView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-14.
//

import SwiftUI

struct ModMailConversationView: View {
    let participantUsername: String

    @StateObject var modMailConversationViewModel: ModMailConversationViewModel

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
            Text("ModMailConversationView")
        }
        .task {
            await modMailConversationViewModel.initialLoadModMailConversation()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar(participantUsername)
        .showErrorUsingSnackbar(modMailConversationViewModel.$error)
    }
}
