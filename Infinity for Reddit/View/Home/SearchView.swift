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
        ScrollView {
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
                            if !accountViewModel.account.isAnonymous() {
                                searchViewModel.saveSearchQuery()
                            }
                            navigationManager.path.append(AppNavigation.search(query: searchViewModel.query, searchInSubredditOrUserName: "", searchInMultiReddit: "", searchInThingType: SearchInThingType.all.rawValue))
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
                            searchViewModel.clearAllRecentSearchQueries()
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                }
                
                // Recent search items
                VStack(spacing: 12) {
                    ForEach(searchViewModel.recentSearchQueries, id: \.time) { search in
                        TouchRipple(action: {
                            navigationManager.path.append(AppNavigation.search(query: search.searchQuery, searchInSubredditOrUserName: search.searchInSubredditOrUserName, searchInMultiReddit: search.multiRedditPath, searchInThingType: search.searchInThingType))
                        }) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(search.searchQuery)
                                    .primaryText()
                                
                                switch search.searchInThingType {
                                case SearchInThingType.all.rawValue:
                                    Text("All subreddits")
                                        .secondaryText()
                                case SearchInThingType.subreddit.rawValue:
                                    Text("r/\(search.searchInSubredditOrUserName ?? "")")
                                        .subreddit()
                                case SearchInThingType.user.rawValue:
                                    Text("u/\(search.searchInSubredditOrUserName ?? "")")
                                        .username()
                                case SearchInThingType.multireddit.rawValue:
                                    Text(search.multiRedditDisplayName ?? "")
                                        .secondaryText()
                                default:
                                    Text("All subreddits")
                                        .secondaryText()
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .contentShape(Rectangle())
                        }
                    }
                }
                Spacer()
            }
            .onTapGesture {
                isTextFieldFocused = false
            }
        }
        .rootViewBackground()
    }
}
