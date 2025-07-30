//
//  InboxConversationView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-21.
//

import SwiftUI

struct InboxConversationView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @StateObject var inboxConversationViewModel: InboxConversationViewModel
    
    @State private var scrollToBottomTrigger: Bool = false
    @State private var messageText: String = ""
    @State private var sendMessageTask: Task<Void, Never>?
    @FocusState private var isInputActive: Bool
    
    init(inbox: Inbox) {
        _inboxConversationViewModel = StateObject(
            wrappedValue: InboxConversationViewModel(
                inbox: inbox,
                inboxConversationRepository: InboxConversationRepository()
            )
        )
    }
    
    var body: some View {
//        UICollectionViewList(
//            items: inboxConversationViewModel.conversations,
//            viewForItem: { inbox in
//                AnyView(
//                    VStack {
//                        ChatBubble(isSentMessage: true, shouldShowTail: false) {
//                            Text(inbox.body)
//                        }
//                        ChatBubble(isSentMessage: true, shouldShowTail: true) {
//                            Text(inbox.body)
//                        }
//                        ChatBubble(isSentMessage: false, shouldShowTail: false) {
//                            Text(inbox.body)
//                        }
//                        ChatBubble(isSentMessage: false, shouldShowTail: true) {
//                            Text(inbox.body)
//                        }
//                    }
//                )
//            },
//            onItemAppear: { index, inbox in
//                
//            },
//            scrollFromBottom: true,
//            scrollToBottomTrigger: $scrollToBottomTrigger
//        )
//        .onAppear {
//            self.scrollToBottomTrigger = true
//        }
//        .themedNavigationBar()
        
//        VStack(spacing: 0) {
//            Spacer()
//            
//            ScrollViewReader { proxy in
//                List(inboxConversationViewModel.conversations, id: \.id) { inbox in
//                    ChatBubble(isSentMessage: true, shouldShowTail: false) {
//                        Text(inbox.body)
//                    }
//                    .listPlainItemNoInsets()
//                    .id(inbox.id)
//                    
//                    Text("fuck you")
//                }
//                .themedList()
//                .onAppear {
//                    print("view appeared")
//                    withAnimation {
//                        proxy.scrollTo(inboxConversationViewModel.conversations.last?.id, anchor: .bottom)
//                    }
//                }
//            }
//        }
//        .frame(maxHeight: .infinity)
//        .themedNavigationBar()
        
        VStack(spacing: 0) {
            List {
                let conversations = inboxConversationViewModel.conversations
                
                ForEach(Array(conversations.enumerated()), id: \.element.id) { index, inbox in
                    // Remember the conversations is reversed.
                    let isLastFromSender = index == 0 || conversations[index - 1].author != inbox.author
                    
                    ChatBubble(isSentMessage: inbox.author == accountViewModel.account.username, shouldShowTail: isLastFromSender) {
                        Text(inbox.body)
                    }
                    .listPlainItemNoInsets()
                    .rotationEffect(.degrees(180))
                    .id(inbox.id)
                }
            }
            .rotationEffect(.degrees(180))
            .themedList()
            .scrollIndicators(.hidden)
            .onTapGesture {
                isInputActive = false
            }
            
            if inboxConversationViewModel.fullNameToReplyTo != nil {
                // It shouldn't happen but still
                HStack(spacing: 8) {
                    TextField("Type a message...", text: $messageText)
                        .focused($isInputActive)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .submitLabel(.send)
                        .onSubmit {
                            guard sendMessageTask == nil else {
                                print("A message is being sent")
                                return
                            }
                            
                            sendMessageTask = Task {
                                defer {
                                    sendMessageTask = nil
                                }
                                
                                await inboxConversationViewModel.sendMessage(message: messageText)
                            }
                        }

                    Button(action: {
                        guard sendMessageTask == nil else {
                            print("A message is being sent")
                            return
                        }
                        
                        sendMessageTask = Task {
                            defer {
                                sendMessageTask = nil
                            }
                            
                            await inboxConversationViewModel.sendMessage(message: messageText)
                        }
                    }) {
                        SwiftUI.Image(systemName: "paperplane.fill")
                            .foregroundColor(messageText.isEmpty ? .gray : .blue)
                            .padding(10)
                    }
                    .disabled(messageText.isEmpty || sendMessageTask != nil)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemBackground))
            }
        }
        .themedNavigationBar()
    }
}

struct InboxConversationMe: View {
    var body: some View {
        EmptyView()
    }
}

struct InboxConversationThem: View {
    var body: some View {
        EmptyView()
    }
}
