//
// SubredditSearchResultSheet.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-09-06
        
import SwiftUI

struct SubredditSearchResultSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    
    @StateObject private var subredditListingViewModel: SubredditListingViewModel
    
    private let query: String
    
    init(query: String, onThingSelected: @escaping (Thing) -> Void) {
        self.query = query
        _subredditListingViewModel = StateObject(
            wrappedValue: SubredditListingViewModel(
                query: query,
                thingSelectionMode: .thingSelection(onSelectThing: { thing in
                    onThingSelected(thing)
                }),
                subredditListingRepository: SubredditListingRepository()
            )
        )
    }
    
    var body: some View {
        SubredditListingView(account: accountViewModel.account, subredditListingViewModel: subredditListingViewModel)
            .themedNavigationBar()
            .addTitleToInlineNavigationBar("Subreddits")
            .id(accountViewModel.account.username)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .navigationBarPrimaryText()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationBarMenu()
                }
            }
    }
}

