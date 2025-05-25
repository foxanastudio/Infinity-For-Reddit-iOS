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
            if inboxListingViewModel.isInitialLoading || inboxListingViewModel.isInitialLoad {
                ProgressIndicator()
            } else if inboxListingViewModel.inboxes.isEmpty {
                Text("No inboxes")
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
    @State var inbox: Inbox
    private let account: Account
    
    init(inbox: Inbox, account: Account) {
        self.inbox = inbox
        self.account = account
    }
    
    var body: some View {
        VStack {
            Text(account.username == inbox.author ? inbox.dest : inbox.author)
                .frame(maxWidth: .infinity, alignment: .leading)
                .primaryText()
            
            Text(inbox.subject)
                .frame(maxWidth: .infinity, alignment: .leading)
                .primaryText()
            
            Text(inbox.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .primaryText()
            
            Divider()
        }
        .contentShape(Rectangle())
        .listPlainItem()
        .onTapGesture {
            //navigationManager.path.append(AppNavigation.inboxDetails(inboxname: inbox.name))
        }
    }
}

struct InboxNotificationItemView: View {
    @State var inbox: Inbox
    private let account: Account
    
    init(inbox: Inbox, account: Account) {
        self.inbox = inbox
        self.account = account
    }
    
    var body: some View {
        VStack {
            Text(inbox.author)
                .frame(maxWidth: .infinity, alignment: .leading)
                .primaryText()
            
            Text(inbox.linkTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .primaryText()
            
            Text(inbox.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .primaryText()
            
            Divider()
        }
        .contentShape(Rectangle())
        .listPlainItem()
        .onTapGesture {
            //navigationManager.path.append(AppNavigation.inboxDetails(inboxname: inbox.name))
        }
    }
}
