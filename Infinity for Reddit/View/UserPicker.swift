//
//  UserPicker.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-18.
//

import SwiftUI

struct UserPicker: View {
    @StateObject var userPickerViewModel: UserPickerViewModel
    var onAccountSelected: (Account) -> Void
    
    init(onAccountSelected: @escaping (Account) -> Void) {
        self.onAccountSelected = onAccountSelected
        _userPickerViewModel = StateObject(
            wrappedValue: UserPickerViewModel()
        )
    }
    
    var body: some View {
        Menu {
            ForEach(userPickerViewModel.allAccounts, id: \.self) { account in
                Button {
                    userPickerViewModel.selectedAccount = account
                    onAccountSelected(account)
                } label: {
                    SimpleWebImageTouchItemRow(text: account.username, iconUrl: account.profileImageUrl ?? "")
                }
            }
        } label: {
            SimpleWebImageTouchItemRow(text: userPickerViewModel.selectedAccount.username, iconUrl: userPickerViewModel.selectedAccount.profileImageUrl)
        }
    }
}
