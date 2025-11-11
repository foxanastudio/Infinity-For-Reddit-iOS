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
    
    init(messageWhere: MessageWhere) {
        _inboxListingViewModel = StateObject(
            wrappedValue: InboxListingViewModel(
                messageWhere: messageWhere,
                inboxListingRepository: InboxListingRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            if inboxListingViewModel.inboxes.isEmpty {
                ZStack {
                    if inboxListingViewModel.isInitialLoading || inboxListingViewModel.isInitialLoad {
                        ProgressIndicator()
                    } else {
                        Text("No items")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(inboxListingViewModel.inboxes, id: \.id) { inbox in
                        if inboxListingViewModel.messageWhere == .messages {
                            InboxMessageItemView(inbox: inbox)
                        } else {
                            InboxNotificationItemView(inbox: inbox)
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
            }
        }
        .task(id: inboxListingViewModel.loadInboxFlag) {
            await inboxListingViewModel.initialLoadInboxes()
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Refresh") {
                    inboxListingViewModel.refreshInboxes()
                }
            ])
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
    
    @State var inbox: Inbox
    private let account: Account
    
    init(inbox: Inbox) {
        self.inbox = inbox
        self.account = AccountViewModel.shared.account
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TouchRipple(action: {
                navigationManager.path.append(AppNavigation.inboxConversation(inbox: inbox))
            }) {
                VStack {
                    Text(account.username == inbox.author ? inbox.dest : inbox.author)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .username()
                    
                    Text(inbox.subject)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .primaryText()
                    
                    Text(inbox.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .secondaryText()
                }
                .contentShape(Rectangle())
                .padding(16)
            }
            
            Divider()
        }
        .listPlainItemNoInsets()
    }
}

struct InboxNotificationItemView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @State var inbox: Inbox
    private let account: Account
    
    init(inbox: Inbox) {
        self.inbox = inbox
        self.account = AccountViewModel.shared.account
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TouchRipple(action: {
                navigationManager.openLink(inbox.context)
            }) {
                VStack {
                    Text(inbox.author)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .username()
                    
                    Text(inbox.linkTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .primaryText()
                    
                    Text(inbox.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .secondaryText()
                }
                .contentShape(Rectangle())
                .padding(16)
            }
            
            Divider()
        }
        .listPlainItemNoInsets()
    }
}
