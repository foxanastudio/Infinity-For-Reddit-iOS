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
            
            ZStack {
                InboxListingView(account: account, messageWhere: MessageWhere.inbox)
                    .opacity(selectedOption == 0 ? 1 : 0)
                
                InboxListingView(account: account, messageWhere: MessageWhere.messages)
                    .opacity(selectedOption == 1 ? 1 : 0)
            }
            
            Spacer()
        }
    }
}
