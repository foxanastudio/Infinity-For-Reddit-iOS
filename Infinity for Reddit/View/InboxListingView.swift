//
//  InboxListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-23.
//

import SwiftUI

struct InboxListingView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var navigationManager: NavigationManager
    
    @StateObject var inboxListingViewModel: InboxListingViewModel
    private let account: Account
    
    init(account: Account, messageWhere: MessageWhere) {
        self.account = account
        
        _inboxListingViewModel = StateObject(
            wrappedValue: InboxListingViewModel(
                messageWhere: messageWhere,
                inboxListingRepository: InboxListingRepository()
            )
        )
    }
    
    var body: some View {
        Group {
            if inboxListingViewModel.inboxes.isEmpty {
                if inboxListingViewModel.isInitialLoading || inboxListingViewModel.isInitialLoad {
                    ProgressIndicator()
                } else {
                    Text("No inboxes")
                }
            } else {
                List {
                    ForEach(inboxListingViewModel.inboxes, id: \.id) { inbox in
                        if inboxListingViewModel.messageWhere == .messages {
                            InboxMessageItemView(inbox: inbox, account: account)
                        } else {
                            InboxNotificationItemView(inbox: inbox, account: account)
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
        .onChange(of: colorScheme) {
            //print(colorScheme == .dark)
        }
        .task {
            await inboxListingViewModel.initialLoadInboxes()
        }
    }
}

struct InboxMessageItemView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    @State var inbox: Inbox
    private let account: Account
    
    init(inbox: Inbox, account: Account) {
        self.inbox = inbox
        self.account = account
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
    
    init(inbox: Inbox, account: Account) {
        self.inbox = inbox
        self.account = account
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
