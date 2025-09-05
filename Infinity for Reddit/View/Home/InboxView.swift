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
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @State private var selectedOption = 0
    
    private let account: Account
    
    init(account: Account) {
        self.account = account
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SegmentedPicker(selectedValue: $selectedOption, values: ["Notifications", "Messages"])
                .padding(4)
            
            TabView(selection: $selectedOption) {
                InboxListingView(account: account, messageWhere: MessageWhere.inbox)
                    .tag(0)
                
                InboxListingView(account: account, messageWhere: MessageWhere.messages)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Spacer()
        }
        .rootViewBackground()
        .onAppear {
            applyPendingRouteIfAny()
        }
        .onChange(of: homeViewModel.pendingInboxRoute, initial: true) { _, _  in
            applyPendingRouteIfAny()
        }
    }
    
    private func applyPendingRouteIfAny() {
        if let route = homeViewModel.pendingInboxRoute {
            selectedOption = route.viewMessage ? 1 : 0
            homeViewModel.pendingInboxRoute = nil 
        }
    }
}
