//
//  SelectSearchInThingSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-20.
//

import SwiftUI

struct SelectSearchInThingSheet: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSearchSubredditsAndUsersView: Bool = false
    
    let onSelectThing: (Thing) -> Void
    
    var body: some View {
        ZStack {
            if accountViewModel.account.isAnonymous() {
                AnonymousSubscriptionsView(subscriptionSelectionMode: .thingSelection(onSelectThing: { thing in
                    onSelectThing(thing)
                    dismiss()
                }))
            } else {
                SubscriptionsView(subscriptionSelectionMode: .thingSelection(onSelectThing: { thing in
                    onSelectThing(thing)
                    dismiss()
                }))
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
                SearchSubredditsAndUsersSheet(thingSelectionMode: .thingSelection(onSelectThing: { thing in
                    onSelectThing(thing)
                    dismiss()
                }))
            }
        }
    }
}
