//
//  InboxConversationView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-21.
//

import SwiftUI

struct InboxConversationView: View {
    @StateObject var inboxConversationViewModel: InboxConversationViewModel
    
    @State private var scrollToBottomTrigger: Bool = false
    
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
            List(inboxConversationViewModel.conversations, id: \.id) { inbox in
                ChatBubble(isSentMessage: true, shouldShowTail: false) {
                    Text(inbox.body)
                }
                .listPlainItemNoInsets()
                .rotationEffect(.degrees(180))
                .id(inbox.id)
            }
            .rotationEffect(.degrees(180))
            .themedList()
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
