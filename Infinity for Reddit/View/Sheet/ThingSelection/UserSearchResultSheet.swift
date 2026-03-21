//
//  UserSearchResultSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-14.
//

import SwiftUI

struct UserSearchResultSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    
    @StateObject private var userListingViewModel: UserListingViewModel
    
    private let query: String
    
    init(query: String, onThingSelected: @escaping (Thing) -> Void) {
        self.query = query
        _userListingViewModel = StateObject(
            wrappedValue: UserListingViewModel(
                query: query,
                thingSelectionMode: .thingSelection(onSelectThing: { thing in
                    onThingSelected(thing)
                }),
                userListingRepository: UserListingRepository()
            )
        )
    }
    
    var body: some View {
        UserListingView(account: accountViewModel.account, userListingViewModel: userListingViewModel)
            .themedNavigationBar()
            .addTitleToInlineNavigationBar("Users")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .navigationBarPrimaryText()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationBarMenu()
                }
            }
    }
}
