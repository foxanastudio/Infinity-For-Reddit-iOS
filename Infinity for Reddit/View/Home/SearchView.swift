//
//  SearchView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-18.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    
    @StateObject private var searchViewModel: SearchViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    init(username: String) {
        _searchViewModel = StateObject(wrappedValue: SearchViewModel(username: username))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Search bar
            HStack(spacing: 8) {
                SwiftUI.Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search", text: $searchViewModel.query)
                .focused($isTextFieldFocused)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .submitLabel(.search)
                .onSubmit {
                    navigationManager.path.append(AppNavigation.search(query: searchViewModel.query, searchInSubredditOrUserName: "", searchInMultiReddit: "", searchInThingType: SearhInThingType.subreddit))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .padding(.top, 12)
            .padding(.horizontal)
            
            // Recent Searches Header
            if !searchViewModel.recentSearchQueries.isEmpty {
                HStack {
                    Text("Recent Searches")
                        .font(.headline)
                    Spacer()
                    Button("Clear All") {
                        // Clear logic here
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
            
            // Recent search items
            VStack(spacing: 12) {
                ForEach(searchViewModel.recentSearchQueries, id: \.time) { search in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(search.searchQuery)
                            .font(.body)
                            .fontWeight(.medium)
                        Text(search.searchQuery)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
            }
            Spacer()
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}
