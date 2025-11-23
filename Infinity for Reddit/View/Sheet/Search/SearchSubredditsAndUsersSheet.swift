//
//  SearchSubredditsAndUsersSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-20.
//

import SwiftUI

struct SearchSubredditsAndUsersSheet: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State private var queryItem: Item?
    
    var thingSelectionMode: ThingSelectionMode
    
    var body: some View {
        SearchView { query in
            queryItem = Item(query: query)
        }
        .id(accountViewModel.account.username)
        .addTitleToInlineNavigationBar("Search Subreddits and Users")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .navigationBarPrimaryText()
                }
            }
        }
        .sheet(item: $queryItem) { queryItem in
            NavigationStack {
                SubredditAndUserSearchResultSheet(query: queryItem.query, thingSelectionMode: modifiedThingSelectionMode)
            }
        }
        
        var modifiedThingSelectionMode: ThingSelectionMode {
            switch thingSelectionMode {
            case .noSelection:
                return thingSelectionMode
            case .thingSelection(onSelectThing: let onSelectThing):
                return .thingSelection(onSelectThing: { thing in
                    onSelectThing(thing)
                    dismiss()
                })
            case .subredditAndUserMultiSelection(selectedSubredditsAndUsers: let selectedSubredditsAndUsers, onConfirmSelection: let onConfirmSelection):
                return .subredditAndUserMultiSelection(selectedSubredditsAndUsers: selectedSubredditsAndUsers, onConfirmSelection: { things in
                    onConfirmSelection(things)
                    dismiss()
                })
            }
        }
    }
    
    private struct Item: Identifiable {
        let id = UUID()
        let query: String
    }
}
