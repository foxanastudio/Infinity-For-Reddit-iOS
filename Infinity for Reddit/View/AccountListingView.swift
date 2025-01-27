//
//  AccountListingView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-01-21.
//
import SwiftUI
import Swinject
import GRDB

import SwiftUI

struct AccountListingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var accountListingViewModel: AccountListingViewModel
    var dismissAccountSheet: () -> Void
    
    init(dismissAccountSheet: @escaping () -> Void) {
        self.dismissAccountSheet = dismissAccountSheet
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        
        _accountListingViewModel = StateObject(wrappedValue: AccountListingViewModel(dbPool: resolvedDBPool))
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Current Account
                AccountRow(dismissAccountSheet: dismissAccountSheet, account: accountListingViewModel.currentAccount, isCurrent: true)
                
                // Other Accounts
                if !accountListingViewModel.otherAccounts.isEmpty {
                    
                    ForEach(accountListingViewModel.otherAccounts, id: \.username) { account in
                        // Divider
                        Rectangle()
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.gray.opacity(0.5))
                            .padding(.horizontal, -7)
                        
                        AccountRow(dismissAccountSheet: dismissAccountSheet, account: account, isCurrent: false)
                    }
                }
                
            }
            .padding(.horizontal, 24)
            .background(Color.white)
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    .padding(.horizontal, 16)
            )
            Spacer()
        } 
        .navigationBarTitle("Switch Account", displayMode: .inline)
    }
}
