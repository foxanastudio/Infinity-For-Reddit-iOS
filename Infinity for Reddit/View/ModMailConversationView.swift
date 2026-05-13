//
//  ModMailConversationView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-14.
//

import SwiftUI
import MarkdownUI

struct ModMailConversationView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @StateObject var modMailConversationViewModel: ModMailConversationViewModel
    
    @State private var messageText: String = ""
    @State private var sendMessageTask: Task<Void, Never>?
    @State private var navigationBarMenuKey: UUID?
    @State private var selectedReplyAsOption: ModMailReplyAsOption
    @FocusState private var focusedField: FieldType?
    
    init(conversation: ModMailConversation) {
        _modMailConversationViewModel = StateObject(
            wrappedValue: ModMailConversationViewModel(
                conversation: conversation,
                modMailConversationRepository: ModMailConversationRepository()
            )
        )
        _selectedReplyAsOption = State(initialValue: conversation.isInternal == true ? .modsOnly : .subreddit)
    }
    
    var body: some View {
        RootView {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    List {
                        let messages = modMailConversationViewModel.modMailConversationDetail?.orderedMessages.reversed() ?? []
                        
                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                            let isLastFromSender = index == 0 || messages[index - 1].author.name != message.author.name
                            let isSentMessage = isSentModMailMessage(message)
                            
                            ChatBubble(isSentMessage: isSentMessage, shouldShowTail: isLastFromSender) {
                                Markdown(message.displayBody)
                                    .themedChatMessageMarkdown(
                                        isSentMessage: isSentMessage
                                    )
                                    .markdownLinkHandler { url in
                                        navigationManager.openLink(url)
                                    }
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
                
                if modMailConversationViewModel.modMailConversationDetail?.conversation.isRepliable == true {
                    VStack(spacing: 12) {
                        ModMailReplyAsPicker(
                            selectedReplyAsOption: $selectedReplyAsOption,
                            subredditName: modMailConversationViewModel.conversation.owner.displayName,
                            currentAccount: accountViewModel.account
                        )
                        
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
                    }
                    .padding(8)
                }
            }
        }
        .task {
            await modMailConversationViewModel.initialLoadModMailConversation()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar(modMailConversationViewModel.participantUsername)
        .showErrorUsingSnackbar(modMailConversationViewModel.$error)
        .toolbar {
            NavigationBarMenu()
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "View Profile") {
                    navigationManager.append(AppNavigation.userDetails(username: modMailConversationViewModel.participantUsername))
                }
            ])
        }
        .onDisappear {
            guard let navigationBarMenuKey else { return }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
    }
    
    private func sendMessage() {
        guard sendMessageTask == nil else {
            snackbarManager.showSnackbar(.info("A message is being sent"))
            return
        }
        
        let messageToSend = messageText
        let subredditName = modMailConversationViewModel.conversation.owner.displayName ?? ""
        let authorName = selectedReplyAsOption.authorName(
            currentUsername: accountViewModel.account.username,
            subredditName: subredditName
        )
        sendMessageTask = Task {
            await modMailConversationViewModel.sendMessage(
                message: messageToSend,
                authorName: authorName,
                isAuthorHidden: selectedReplyAsOption.isAuthorHidden,
                isInternal: selectedReplyAsOption.isInternal
            )
            self.messageText = ""
            self.sendMessageTask = nil
        }
    }

    private func isSentModMailMessage(_ message: ModMailMessage) -> Bool {
        let authorName = message.author.name.lowercased()
        let currentUsername = accountViewModel.account.username.lowercased()
        let subredditName = (modMailConversationViewModel.conversation.owner.displayName ?? "").lowercased()

        return authorName == currentUsername || authorName == subredditName
    }
    
    private enum FieldType: Hashable {
        case message
    }
}
