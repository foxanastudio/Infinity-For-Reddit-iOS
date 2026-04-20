//
//  ModMailConversationView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-14.
//

import SwiftUI

struct ModMailConversationView: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @StateObject var modMailConversationViewModel: ModMailConversationViewModel
    
    @State private var messageText: String = ""
    @State private var sendMessageTask: Task<Void, Never>?
    @FocusState private var focusedField: FieldType?
    
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
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
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
                    .onTapGesture {
                        focusedField = nil
                    }
                    .onChange(of: modMailConversationViewModel.listScrollTarget) {
                        guard let target = modMailConversationViewModel.listScrollTarget else { return }
                        
                        proxy.scrollTo(target, anchor: .bottom)
                    }
                }
                
                HStack(spacing: 12) {
                    CustomTextField(
                        "Type a message...",
                        text: $messageText,
                        showBackground: false,
                        fieldType: .message,
                        focusedField: $focusedField
                    )
                    .submitLabel(.send)
                    .lineLimit(3)
                    .onSubmit {
                        sendMessage()
                    }
                    
                    Button(action: {
                        sendMessage()
                    }) {
                        SwiftUI.Image(systemName: "paperplane.fill")
                            .foregroundColor(Color(hex: messageText.isEmpty ? customThemeViewModel.currentCustomTheme.secondaryTextColor : customThemeViewModel.currentCustomTheme.colorPrimaryLightTheme))
                    }
                    .disabled(messageText.isEmpty || sendMessageTask != nil)
                }
                .padding(12)
                .background(Color(hex: customThemeViewModel.currentCustomTheme.filledCardViewBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .clipped()
                .padding(8)
            }
        }
        .task {
            await modMailConversationViewModel.initialLoadModMailConversation()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar(participantUsername)
        .showErrorUsingSnackbar(modMailConversationViewModel.$error)
    }
    
    private func sendMessage() {
        guard sendMessageTask == nil else {
            snackbarManager.showSnackbar(.info("A message is being sent"))
            return
        }
        
        let messageToSend = messageText
        sendMessageTask = Task {
            await modMailConversationViewModel.sendMessage(
                message: messageToSend,
                authorName: accountViewModel.account.username,
                isAuthorHidden: true,
                isInternal: false
            )
            self.messageText = ""
            self.sendMessageTask = nil
        }
    }
    
    private enum FieldType: Hashable {
        case message
    }
}
