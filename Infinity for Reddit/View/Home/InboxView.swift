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
        .onReceive(NotificationCenter.default.publisher(for: .inboxDeepLink)) { note in
            let viewMessage = (note.userInfo?["viewMessage"] as? Bool) ?? false
            selectedOption = viewMessage ? 1 : 0
        }
    }
}
