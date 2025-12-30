//
//  InboxListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-23.
//

import SwiftUI

struct InboxListingView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    
    @StateObject var inboxListingViewModel: InboxListingViewModel
    @State private var navigationBarMenuKey: UUID?
    
    @Binding private var hasReadAllMessages: Bool
    
    let isPresented: Bool
    
    init(messageWhere: MessageWhere, hasReadAllMessages: Binding<Bool>, isPresented: Bool) {
        self._hasReadAllMessages = hasReadAllMessages
        _inboxListingViewModel = StateObject(
            wrappedValue: InboxListingViewModel(
                messageWhere: messageWhere,
                inboxListingRepository: InboxListingRepository()
            )
        )
        self.isPresented = isPresented
    }
    
    var body: some View {
        RootView {
            if inboxListingViewModel.inboxes.isEmpty {
                ZStack {
                    if inboxListingViewModel.isInitialLoading || inboxListingViewModel.isInitialLoad {
                        ProgressIndicator()
                    } else if inboxListingViewModel.isInitialLoad, let error = inboxListingViewModel.error {
                        Text("Unable to load inbox. Tap to retry. Error: \(error.localizedDescription)")
                            .primaryText()
                            .padding(16)
                            .onTapGesture {
                                inboxListingViewModel.refreshInboxes()
                            }
                    } else {
                        Text("No items")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(inboxListingViewModel.inboxes, id: \.id) { inbox in
                        if inboxListingViewModel.messageWhere == .messages {
                            InboxMessageItemView(inbox: inbox, hasReadAllMessages: hasReadAllMessages) { inboxToMarkAsRead in
                                navigationManager.append(AppNavigation.inboxConversation(inbox: inbox))
                                if let inboxToMarkAsRead {
                                    inboxListingViewModel.markAsRead(inbox: inboxToMarkAsRead)
                                }
                            }
                        } else {
                            InboxNotificationItemView(inbox: inbox, hasReadAllMessages: hasReadAllMessages) {
                                navigationManager.openLink(inbox.context)
                                inboxListingViewModel.markAsRead(inbox: inbox)
                            }
                        }
                    }
                    if inboxListingViewModel.hasMorePages {
                        ProgressIndicator()
                            .task {
                                await inboxListingViewModel.loadInboxes()
                            }
                            .listPlainItem()
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .themedList()
                .showErrorUsingSnackbar(inboxListingViewModel.$error)
            }
        }
        .task(id: inboxListingViewModel.loadInboxFlag) {
            await inboxListingViewModel.initialLoadInboxes()
        }
        .onChange(of: isPresented, initial: true) { _, presented in
            if presented {
                if let key = navigationBarMenuKey {
                    navigationBarMenuManager.pop(key: key)
                }

                navigationBarMenuKey = navigationBarMenuManager.push([
                    NavigationBarMenuItem(title: "Refresh") {
                        hasReadAllMessages = false
                        inboxListingViewModel.refreshInboxes()
                    }
                ])
            } else {
                guard let navigationBarMenuKey else {
                    return
                }
                navigationBarMenuManager.pop(key: navigationBarMenuKey)
            }
        }
        .onDisappear {
            guard let navigationBarMenuKey else {
                return
            }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
    }
}

struct InboxMessageItemView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @State var inbox: Inbox
    private let hasReadAllMessages: Bool
    private let onTap: (Inbox?) -> Void
    private let account: Account
    
    init(inbox: Inbox, hasReadAllMessages: Bool, onTap: @escaping (Inbox?) -> Void) {
        self.inbox = inbox
        self.hasReadAllMessages = hasReadAllMessages
        self.onTap = onTap
        self.account = AccountViewModel.shared.account
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TouchRipple(action: {
                onTap(inboxToMarkAsRead)
            }) {
                VStack(spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        RowText(account.username == inbox.author ? inbox.dest : inbox.author)
                            .username()
                        
                        Spacer()
                        
                        TimeText(timeUTCInSeconds: time, forceShowElapsedTime: true)
                            .primaryText()
                    }
                    
                    RowText(inbox.subject)
                        .primaryText()
                    
                    RowText(lastMessage)
                        .lineLimit(1)
                        .secondaryText()
                }
                .contentShape(Rectangle())
                .padding(16)
                .background(isNew && !hasReadAllMessages ? Color(hex: customThemeViewModel.currentCustomTheme.unreadMessageBackgroundColor) : .clear)
            }
            
            CustomDivider()
        }
        .listPlainItemNoInsets()
    }
    
    private var time: Int64 {
        if let replies = inbox.replies?.data?.inboxes, let lastReply = replies.last {
            return lastReply.createdUtc
        } else {
            return inbox.createdUtc
        }
    }
    
    private var lastMessage: String {
        if let replies = inbox.replies?.data?.inboxes, let lastReply = replies.last {
            return lastReply.body
        } else {
            return inbox.body
        }
    }
    
    private var isNew: Bool {
        if let replies = inbox.replies?.data?.inboxes, let lastReply = replies.last {
            return lastReply.isNew
        } else {
            return inbox.isNew
        }
    }
    
    private var inboxToMarkAsRead: Inbox? {
        if let replies = inbox.replies?.data?.inboxes, let lastReply = replies.last {
            return lastReply.isNew ? lastReply : nil
        } else {
            return inbox.isNew ? inbox : nil
        }
    }
}

struct InboxNotificationItemView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @State var inbox: Inbox
    private let hasReadAllMessages: Bool
    private let onTap: () -> Void
    
    init(inbox: Inbox, hasReadAllMessages: Bool, onTap: @escaping () -> Void) {
        self.inbox = inbox
        self.hasReadAllMessages = hasReadAllMessages
        self.onTap = onTap
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TouchRipple(action: {
                onTap()
            }) {
                VStack(spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        RowText(inbox.author)
                            .username()
                        
                        Spacer()
                        
                        TimeText(timeUTCInSeconds: inbox.createdUtc, forceShowElapsedTime: true)
                            .primaryText()
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        RowText(inbox.linkTitle)
                            .primaryText()
                        
                        Spacer()
                        
                        Text(inbox.subject.capitalizedFirst)
                            .secondaryText()
                    }
                    
                    RowText(inbox.body)
                        .lineLimit(1)
                        .secondaryText()
                }
                .contentShape(Rectangle())
                .padding(16)
                .background(inbox.isNew && !hasReadAllMessages ? Color(hex: customThemeViewModel.currentCustomTheme.unreadMessageBackgroundColor) : .clear)
            }
            
            CustomDivider()
        }
        .listPlainItemNoInsets()
    }
}
