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
    
    let onThingSelected: (SearchInThing) -> Void
    
    var body: some View {
        SearchView { query in
            queryItem = Item(query: query)
        }
        .id(accountViewModel.account.username)
        .addTitleToInlineNavigationBar("Search Subreddits and Users")
        .sheet(item: $queryItem) { queryItem in
            NavigationStack {
                SubredditAndUserSearchResultSheet(query: queryItem.query) { searchInThing in
                    onThingSelected(searchInThing)
                    dismiss()
                }
            }
        }
    }
    
    private struct Item: Identifiable {
        let id = UUID()
        let query: String
    }
}
