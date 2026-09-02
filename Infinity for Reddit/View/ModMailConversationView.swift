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
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    @EnvironmentObject private var modMailShareableViewModel: ModMailShareableViewModel
    
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
            if let modMailConversationDetail = modMailConversationViewModel.modMailConversationDetail,
               let modMailMessages = modMailConversationViewModel.modMailConversationDisplayMessages {
                VStack(spacing: 0) {
                    if modMailMessages.isEmpty {
                        Spacer()
                        
                        Text("No message")
                            .primaryText()
                        
                        Spacer()
                    } else {
                        ScrollViewReader { proxy in
                            List {
                                ForEach(Array(modMailMessages.enumerated()), id: \.element.id) { index, modMailMessage in
                                    ModMailMessageBubble(
                                        isSentMessage: modMailMessage.isSentMessage,
                                        shouldShowTail: index == 0 || modMailMessages[index - 1].message.author.name != modMailMessage.message.author.name || modMailMessages[index - 1].isInternal != modMailMessage.isInternal,
                                        modMailSenderLabel: modMailMessage.modMailSenderLabel,
                                        isInternal: modMailMessage.isInternal
                                    ) {
                                        Markdown(modMailMessage.message.displayBody)
                                            .themedChatMessageMarkdown(
                                                isSentMessage: modMailMessage.isSentMessage
                                            )
                                            .markdownLinkHandler { url in
                                                navigationManager.openLink(url)
                                            }
                                    }
                                    .listPlainItemNoInsets()
                                    .rotationEffect(.degrees(180))
                                    .id(modMailMessage.id)
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
                    }
                    
                    if modMailConversationDetail.conversation.isRepliable {
                        VStack(spacing: 12) {
                            ModMailReplyAsPicker(
                                selectedReplyAsOption: $selectedReplyAsOption,
                                subredditName: modMailConversationViewModel.conversation.owner.displayName
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
            } else {
                ZStack {
                    if modMailConversationViewModel.isLoading {
                        ProgressIndicator()
                    } else if let error = modMailConversationViewModel.error {
                        Text("Unable to load mod mail. Tap to retry. Error: \(error.localizedDescription)")
                            .primaryText()
                            .padding(16)
                            .onTapGesture {
                                modMailConversationViewModel.refreshModMailConversation()
                            }
                    } else {
                        Text("No message")
                            .primaryText()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: modMailConversationViewModel.loadConversationFlag) {
            await modMailConversationViewModel.loadModMailConversation()
            if let detail = modMailConversationViewModel.modMailConversationDetail {
                modMailShareableViewModel.updatedConversationDetail = detail
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar(modMailConversationViewModel.participantUsername)
        .showErrorUsingSnackbar(modMailConversationViewModel.$sendMessageError)
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
        let authorName = selectedReplyAsOption.getAuthorName(
            subredditName: subredditName
        )
        sendMessageTask = Task {
            let detail = await modMailConversationViewModel.sendMessage(
                message: messageToSend,
                authorName: authorName,
                isAuthorHidden: selectedReplyAsOption.isAuthorHidden,
                isInternal: selectedReplyAsOption.isInternal
            )
            
            if let detail {
                modMailShareableViewModel.updatedConversationDetail = detail
                self.messageText = ""
            }
            self.sendMessageTask = nil
        }
    }
    
    private enum FieldType: Hashable {
        case message
    }
}
