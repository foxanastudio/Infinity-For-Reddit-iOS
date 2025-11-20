//
//  SubredditAndUserMultiSelectionSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import SwiftUI

struct SubredditAndUserMultiSelectionSheet: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSearchSubredditsAndUsersView: Bool = false
    
    var subscriptionSelectionMode: SubscriptionSelectionMode
    
    var body: some View {
        ZStack {
            if accountViewModel.account.isAnonymous() {
                AnonymousSubscriptionsView(subscriptionSelectionMode: subscriptionSelectionMode)
            } else {
                SubscriptionsView(subscriptionSelectionMode: subscriptionSelectionMode)
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Subscriptions")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .navigationBarPrimaryText()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSearchSubredditsAndUsersView = true
                } label: {
                    SwiftUI.Image(systemName: "magnifyingglass")
                }
            }
        }
        .sheet(isPresented: $showSearchSubredditsAndUsersView) {
            NavigationStack {
                SearchSubredditsAndUsersSheet { searchInThing in
                    dismiss()
                }
            }
        }
    }
}
