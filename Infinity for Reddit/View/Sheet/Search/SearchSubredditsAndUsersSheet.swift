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
        SheetRootView {
            SearchView { query in
                queryItem = Item(query: query)
            }
        }
        .id(accountViewModel.account.username)
        .modify {
            if #unavailable(iOS 26) {
                $0.addTitleToInlineNavigationBar(navigationBarTitle)
            }
        }

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
            case .thingSelection(let onSelectThing):
                return .thingSelection(onSelectThing: { thing in
                    onSelectThing(thing)
                    dismiss()
                })
            case .subredditAndUserMultiSelection(let selectedSubredditsAndUsers, let onConfirmSelection):
                return .subredditAndUserMultiSelection(selectedSubredditsAndUsers: selectedSubredditsAndUsers, onConfirmSelection: { things in
                    onConfirmSelection(things)
                    dismiss()
                })
            case .subredditMultiSelection(let selectedSubreddits, let onConfirmSelection):
                return .subredditMultiSelection(selectedSubreddits: selectedSubreddits, onConfirmSelection: { things in
                    onConfirmSelection(things)
                    dismiss()
                })
            case .userMultiSelection(let selectedUsers, let onConfirmSelection):
                return .userMultiSelection(selectedUsers: selectedUsers, onConfirmSelection: { things in
                    onConfirmSelection(things)
                    dismiss()
                })
            }
        }
    }
    
    private var navigationBarTitle: String {
        switch thingSelectionMode {
        case .subredditMultiSelection(selectedSubreddits: let selectedSubreddits, onConfirmSelection: let onConfirmSelection):
            return "Search Subreddits"
        case .userMultiSelection(selectedUsers: let selectedUsers, onConfirmSelection: let onConfirmSelection):
            return "Search Users"
        default:
            return "Search Subreddits and Users"
        }
    }
    
    private struct Item: Identifiable {
        let id = UUID()
        let query: String
    }
}
