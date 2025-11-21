//
//  SubredditAndUserSearchResultSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-20.
//

import SwiftUI

struct SubredditAndUserSearchResultSheet: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var subredditListingViewModel: SubredditListingViewModel
    @StateObject private var userListingViewModel: UserListingViewModel
    
    @State private var selectedOption = 0
    
    let query: String
    let onSearchInThingSelected: (Thing) -> Void
    
    init(query: String, onSearchInThingSelected: @escaping (Thing) -> Void) {
        self.query = query
        self.onSearchInThingSelected = onSearchInThingSelected
        _subredditListingViewModel = StateObject(
            wrappedValue: SubredditListingViewModel(
                query: query,
                subredditListingRepository: SubredditListingRepository()
            )
        )
        _userListingViewModel = StateObject(
            wrappedValue: UserListingViewModel(
                query: query,
                userListingRepository: UserListingRepository()
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SegmentedPicker(selectedValue: $selectedOption, values: ["Subreddits", "Users"])
                .padding(4)
            
            TabView(selection: $selectedOption) {
                SubredditListingView(account: accountViewModel.account, subredditListingViewModel: subredditListingViewModel) { subreddit in
                    onSearchInThingSelected(Thing.subscribedSubreddit(SubscribedSubredditData.fromSubreddit(subreddit, username: accountViewModel.account.username)))
                    dismiss()
                }
                .tag(0)
                
                UserListingView(account: accountViewModel.account, userListingViewModel: userListingViewModel) { user in
                    onSearchInThingSelected(Thing.subscribedUser(SubscribedUserData.fromUser(user, username: accountViewModel.account.username)))
                    dismiss()
                }
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Button {
                //onSelectMultipleSubscriptions(anonymousSubscriptionListingViewModel.getSelectedSubredditsAndUsersInCustomFeed())
                dismiss()
            } label: {
                HStack {
                    Text("Done")
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
            .filledButton()
        }
        .id(accountViewModel.account.username)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Select a Destination")
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
    }
}
