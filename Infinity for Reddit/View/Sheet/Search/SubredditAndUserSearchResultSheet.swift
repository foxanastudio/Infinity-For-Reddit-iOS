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
    let thingSelectionMode: ThingSelectionMode
    
    init(query: String, thingSelectionMode: ThingSelectionMode) {
        self.query = query
        self.thingSelectionMode = thingSelectionMode
        _subredditListingViewModel = StateObject(
            wrappedValue: SubredditListingViewModel(
                query: query,
                thingSelectionMode: thingSelectionMode,
                subredditListingRepository: SubredditListingRepository()
            )
        )
        _userListingViewModel = StateObject(
            wrappedValue: UserListingViewModel(
                query: query,
                thingSelectionMode: thingSelectionMode,
                userListingRepository: UserListingRepository()
            )
        )
    }
    
    var body: some View {
        SheetRootView {
            VStack(spacing: 0) {
                switch thingSelectionMode {
                case .subredditAndUserMultiSelection:
                    SegmentedPicker(selectedValue: $selectedOption, values: ["Subreddits", "Users"])
                        .padding(4)
                default:
                    EmptyView()
                }
                
                TabView(selection: $selectedOption) {
                    switch thingSelectionMode {
                    case .subredditAndUserMultiSelection:
                        SubredditListingView(account: accountViewModel.account, subredditListingViewModel: subredditListingViewModel)
                            .tag(0)
                        
                        UserListingView(account: accountViewModel.account, userListingViewModel: userListingViewModel)
                            .tag(1)
                    case .subredditMultiSelection:
                        SubredditListingView(account: accountViewModel.account, subredditListingViewModel: subredditListingViewModel)
                            .tag(0)
                    case .userMultiSelection:
                        UserListingView(account: accountViewModel.account, userListingViewModel: userListingViewModel)
                            .tag(0)
                    default:
                        EmptyView()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                switch thingSelectionMode {
                case .subredditAndUserMultiSelection(_, let onSelectMultipleSubscriptions):
                    Button {
                        var selectedThings: [Thing] = []
                        for subreddit in subredditListingViewModel.selectedSubreddits {
                            selectedThings.append(.subreddit(subreddit.toSubredditData()))
                        }
                        for user in userListingViewModel.selectedUsers {
                            selectedThings.append(.user(user.toUserData()))
                        }
                        
                        onSelectMultipleSubscriptions(selectedThings)
                        dismiss()
                    } label: {
                        HStack {
                            Text("Done")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(16)
                    .filledButton()
                case .subredditMultiSelection(_, let onConfirmSelection):
                    Button {
                        var selectedSubreddits: [Thing] = []
                        for subreddit in subredditListingViewModel.selectedSubreddits {
                            selectedSubreddits.append(.subreddit(subreddit.toSubredditData()))
                        }
                        
                        onConfirmSelection(selectedSubreddits)
                        dismiss()
                    } label: {
                        HStack {
                            Text("Done")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(16)
                    .filledButton()
                case .userMultiSelection(_, let onConfirmSelection):
                    Button {
                        var selectedUsers: [Thing] = []
                        for user in userListingViewModel.selectedUsers {
                            selectedUsers.append(.user(user.toUserData()))
                        }
                        
                        onConfirmSelection(selectedUsers)
                        dismiss()
                    } label: {
                        HStack {
                            Text("Done")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(16)
                    .filledButton()
                default:
                    EmptyView()
                }
            }
        }
        .id(accountViewModel.account.username)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Select")
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
