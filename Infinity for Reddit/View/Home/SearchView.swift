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
    @EnvironmentObject var customThemeViewModel: CustomThemeViewModel
    
    @StateObject private var searchViewModel: SearchViewModel
    @FocusState var focusedField: FieldType?
    
    @State private var showSelectSearchInThingSheet: Bool = false
    
    @State private var showSubredditAndUserSearchResultView: Bool = false
    @State private var searchThingQuery: String = ""
    
    @AppStorage(InterfaceUserDefaultsUtils.defaultSearchResultTabKey, store: .interface) private var defaultSearchResultTab: Int = 0
    
    private let onSearchCustomAction: ((String) -> Void)?
    
    init(onSearchCustomAction: ((String) -> Void)? = nil) {
        self.onSearchCustomAction = onSearchCustomAction
        _searchViewModel = StateObject(wrappedValue: SearchViewModel())
    }
    
    var body: some View {
        RootView {
            VStack(alignment: .leading, spacing: 0) {
                // Search bar
                if #available(iOS 26, *) {
                    EmptyView()
                } else {
                    HStack(spacing: 8) {
                        SwiftUI.Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        CustomTextField("Search",
                                        text: $searchViewModel.query,
                                        singleLine: true,
                                        autocapitalization: .never,
                                        showBorder: false,
                                        showBackground: false,
                                        fieldType: .search,
                                        focusedField: $focusedField)
                        .padding(16)
                        .submitLabel(.search)
                        .onSubmit {
                            if !accountViewModel.account.isAnonymous() {
                                searchViewModel.saveSearchQuery()
                            }
                            if let onSearch = onSearchCustomAction {
                                onSearch(searchViewModel.query)
                            } else {
                                navigationManager.append(
                                    AppNavigation.searchResults(
                                        query: searchViewModel.query,
                                        searchInSubredditOrUserName: searchViewModel.searchInSubredditOrUserName,
                                        searchInMultiReddit: searchViewModel.searchInCustomFeed,
                                        searchInThingType: searchViewModel.searchInThingType,
                                        searchResultTab: defaultSearchResultTab
                                    )
                                )
                            }
                        }
                    }
                    .padding(.leading, 12)
                    .background(Color(hex: customThemeViewModel.currentCustomTheme.filledCardViewBackgroundColor))
                    .cornerRadius(10)
                    .padding(16)
                }
                
                if onSearchCustomAction == nil {
                    TouchRipple(action: {
                        showSelectSearchInThingSheet = true
                    }) {
                        HStack(spacing: 32) {
                            Text("Search in")
                                .colorAccentText()
                            
                            if let searchInThing = searchViewModel.searchInThing {
                                RowText(searchInThing.displayName)
                                    .primaryText()
                            } else {
                                RowText("All subreddits")
                                    .primaryText()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .contentShape(Rectangle())
                    }
                    .limitedWidthListItem()
                }
                
                if searchViewModel.query.isEmpty || onSearchCustomAction != nil {
                    // Recent Searches Header
                    if !searchViewModel.recentSearchQueries.isEmpty {
                        HStack {
                            Text("Recent Searches")
                                .primaryText(.f20)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("Clear All") {
                                searchViewModel.clearAllRecentSearchQueries()
                            }
                            .customFont()
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 16)
                        .limitedWidthListItem()
                    }
                    
                    // Recent search items
                    List {
                        ForEach(searchViewModel.recentSearchQueries, id: \.time) { search in
                            TouchRipple(action: {
                                if let onSearch = onSearchCustomAction {
                                    onSearch(search.searchQuery)
                                } else {
                                    navigationManager.append(
                                        AppNavigation.searchResults(
                                            query: search.searchQuery,
                                            searchInSubredditOrUserName: search.searchInSubredditOrUserName,
                                            searchInMultiReddit: search.customFeedPath,
                                            searchInThingType: search.searchInThingType,
                                            searchResultTab: defaultSearchResultTab
                                        )
                                    )
                                }
                            }) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(search.searchQuery)
                                        .primaryText()
                                    
                                    switch search.searchInThingType {
                                    case .all:
                                        Text("All subreddits")
                                            .secondaryText()
                                    case .subreddit:
                                        Text("r/\(search.searchInSubredditOrUserName ?? "")")
                                            .subreddit()
                                    case .user:
                                        Text("u/\(search.searchInSubredditOrUserName ?? "")")
                                            .username()
                                    case .customFeed:
                                        Text(search.customFeedDisplayName ?? "")
                                            .secondaryText()
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .contentShape(Rectangle())
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        searchViewModel.deleteSearchQuery(recentSearchQuery: search)
                                    } label: {
                                        Label("Read", systemImage: "trash")
                                    }
                                    .tint(.red)
                                }
                            }
                            .listPlainItemNoInsets()
                            .limitedWidthListItem()
                        }
                    }
                    .themedList()
                } else {
                    SubredditAutoCompleteView(query: $searchViewModel.query) { subreddit in
                        if !accountViewModel.account.isAnonymous() {
                            searchViewModel.saveSearchQuery()
                        }
                        navigationManager.append(
                            AppNavigation.subredditDetails(subredditName: subreddit.displayName)
                        )
                    }
                }
                
                Spacer()
                
                KeyboardToolbar {
                    focusedField = nil
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .themedNavigationBar()
        .modify {
            if #available(iOS 26, *) {
                $0.toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 8) {
                            SwiftUI.Image(systemName: "magnifyingglass")
                                .padding(4)
                            
                            CustomTextField("Search",
                                            text: $searchViewModel.query,
                                            singleLine: true,
                                            autocapitalization: .never,
                                            showBorder: false,
                                            showBackground: false,
                                            fieldType: .search,
                                            focusedField: $focusedField)
                            .padding(16)
                            .submitLabel(.search)
                            .onSubmit {
                                if !accountViewModel.account.isAnonymous() {
                                    searchViewModel.saveSearchQuery()
                                }
                                if let onSearch = onSearchCustomAction {
                                    onSearch(searchViewModel.query)
                                } else {
                                    navigationManager.append(
                                        AppNavigation.searchResults(
                                            query: searchViewModel.query,
                                            searchInSubredditOrUserName: searchViewModel.searchInSubredditOrUserName,
                                            searchInMultiReddit: searchViewModel.searchInCustomFeed,
                                            searchInThingType: searchViewModel.searchInThingType,
                                            searchResultTab: defaultSearchResultTab
                                        )
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            } else {
                $0.addTitleToInlineNavigationBar("Search")
            }
        }
        .sheet(isPresented: $showSelectSearchInThingSheet) {
            NavigationStack {
                SelectSearchInThingSheet { thing in
                    searchViewModel.searchInThing = thing
                }
            }
        }
        .onAppear {
            focusedField = .search
        }
    }
    
    enum FieldType: Hashable {
        case search
    }
}
