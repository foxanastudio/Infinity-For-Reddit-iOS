//
// SearchSubredditsSheet.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-27
        
import SwiftUI

struct SearchSubredditsSheet: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSubredditSearchResultSheet: Bool = false
    @State private var queryItem: Item?
    
    let onThingSelected: (Thing) -> Void
    
    var body: some View {
        SearchView { query in
            queryItem = Item(query: query)
            showSubredditSearchResultSheet = true
        }
        .themedNavigationBar()
        .modify {
            if #unavailable(iOS 26) {
                $0.addTitleToInlineNavigationBar("Search Subreddits")
            }
        }
        .id(accountViewModel.account.username)
        .sheet(item: $queryItem) { queryItem in
            NavigationStack {
                SubredditSearchResultSheet(query: queryItem.query) { thing in
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
