//
//  InboxView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-03.
//

import SwiftUI
import Swinject
import GRDB

struct InboxView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    @StateObject private var inboxViewModel: InboxViewModel
    @State private var selectedOption = 0
    @State private var navigationBarMenuKey: UUID?
    @State private var hasReadAllMessages: Bool = false
    
    private let account: Account
    
    init(account: Account) {
        self.account = account
        self._inboxViewModel = StateObject(wrappedValue: InboxViewModel(inboxRepository: InboxRepository()))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SegmentedPicker(selectedValue: $selectedOption, values: ["Notifications", "Messages"])
                .padding(4)
            
            TabView(selection: $selectedOption) {
                Group {
                    InboxListingView(messageWhere: MessageWhere.inbox, hasReadAllMessages: $hasReadAllMessages)
                        .tag(0)
                    
                    InboxListingView(messageWhere: MessageWhere.messages, hasReadAllMessages: $hasReadAllMessages)
                        .tag(1)
                }
                .toolbar(.hidden, for: .tabBar)
            }
        }
        .id(accountViewModel.account.username)
        .onAppear {
            applyPendingRouteIfAny()
            
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Read All Messages") {
                    Task {
                        await inboxViewModel.readAllMessages()
                        await MainActor.run {
                            homeViewModel.inboxCount = 0
                            hasReadAllMessages = true
                        }
                    }
                },
                
                NavigationBarMenuItem(title: "Send Chat Message") {
                    navigationManager.append(AppNavigation.sendChatMessage())
                }
            ])
        }
        .onDisappear {
            guard let navigationBarMenuKey else { return }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
        .onChange(of: homeViewModel.inboxNavigationTarget, initial: true) { _, _  in
            applyPendingRouteIfAny()
        }
    }
    
    private func applyPendingRouteIfAny() {
        if let route = homeViewModel.inboxNavigationTarget {
            selectedOption = route.viewMessage ? 1 : 0
            homeViewModel.inboxNavigationTarget = nil 
        }
    }
}
