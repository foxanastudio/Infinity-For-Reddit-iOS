//
//  SearchUsersSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-14.
//

import SwiftUI

struct SearchUsersSheet: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showUserSearchResultSheet: Bool = false
    @State private var queryItem: Item?
    
    let onThingSelected: (Thing) -> Void
    
    var body: some View {
        SearchView { query in
            queryItem = Item(query: query)
            showUserSearchResultSheet = true
        }
        .themedNavigationBar()
        .modify {
            if #unavailable(iOS 26) {
                $0.addTitleToInlineNavigationBar("Search Users")
            }
        }
        .id(accountViewModel.account.username)
        .sheet(item: $queryItem) { queryItem in
            NavigationStack {
                UserSearchResultSheet(query: queryItem.query) { thing in
                    onThingSelected(thing)
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
