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
                        HStack {
                            Spacer()
                                .frame(width: 24)
                            
                            Text(inbox.subject)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .primaryText()
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .listPlainItem()
                        .onTapGesture {
                            //navigationManager.path.append(AppNavigation.inboxDetails(inboxname: inbox.name))
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
