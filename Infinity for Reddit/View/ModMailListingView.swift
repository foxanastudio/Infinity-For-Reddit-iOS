//
//  ModMailListingView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-09.
//

import SwiftUI

struct ModMailListingView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var navigationBarMenuManager: NavigationBarMenuManager

    @StateObject var modMailListingViewModel: ModMailListingViewModel
    @State private var navigationBarMenuKey: UUID?
    
    init() {
        _modMailListingViewModel = StateObject(
            wrappedValue: ModMailListingViewModel(
                modMailListingRepository: ModMailListingRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            if modMailListingViewModel.conversations.isEmpty {
                ZStack {
                    if modMailListingViewModel.isInitialLoading {
                        ProgressIndicator()
                    } else if modMailListingViewModel.isInitialLoad, let error = modMailListingViewModel.error {
                        Text("Unable to load mod mail. Tap to retry. Error: \(error.localizedDescription)")
                            .primaryText()
                            .padding(16)
                            .onTapGesture {
                                modMailListingViewModel.refreshModMailListing()
                            }
                    } else {
                        Text("No items")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(modMailListingViewModel.conversations, id: \.id) { conversation in
                        ModMailConversationItemView(
                            conversation: conversation,
                            latestMessagePreview: modMailListingViewModel.latestMessagePreview(for: conversation),
                            onTap: {
                                navigationManager.append(
                                    AppNavigation.modMailConversation(
                                        conversationId: conversation.id,
                                        participantUsername: conversation.participant.name
                                    )
                                )
                            }
                        )
                        .limitedWidth()
                    }
                    if modMailListingViewModel.hasMorePages {
                        ProgressIndicator()
                            .task {
                                await modMailListingViewModel.loadModMailListing()
                            }
                            .listPlainItem()
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .themedList()
                .showErrorUsingSnackbar(modMailListingViewModel.$error)
            }
        }
        .task(id: modMailListingViewModel.loadModMailFlag) {
            await modMailListingViewModel.initialLoadModMailListing()
        }
        .toolbar {
            NavigationBarMenu()
        }
        .onAppear {
            setUpMenu()
        }
        .onDisappear {
            guard let navigationBarMenuKey else {
                return
            }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
    }

    private func setUpMenu() {
        if let key = navigationBarMenuKey {
            navigationBarMenuManager.pop(key: key)
        }

        navigationBarMenuKey = navigationBarMenuManager.push([
            NavigationBarMenuItem(title: "Refresh") {
                modMailListingViewModel.refreshModMailListing()
            }
        ])
    }
}

struct ModMailConversationItemView: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @State var conversation: ModMailConversation
    let latestMessagePreview: String
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            TouchRipple(action: onTap) {
                VStack(spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        RowText("u/\(conversation.participant.name ?? "-"), \(conversation.replyCount) replies")
                            .username()
                        
                        Spacer()
                        
                        TimeText(timeUTCInSeconds: conversation.lastUpdatedUtc, forceShowElapsedTime: true)
                            .primaryText()
                    }
                    
                    RowText("r/\(conversation.owner.displayName ?? "-")")
                        .primaryText()
                    
                    RowText(conversation.subject)
                        .primaryText()
                    
                    RowText(latestMessagePreview.isEmpty ? "-" : latestMessagePreview)
                        .lineLimit(1)
                        .secondaryText()
                }
                .contentShape(Rectangle())
                .padding(16)
                .background(conversation.isUnread ? Color(hex: customThemeViewModel.currentCustomTheme.unreadMessageBackgroundColor) : .clear)
            }
            
            CustomDivider()
        }
        .listPlainItemNoInsets()
    }
}
