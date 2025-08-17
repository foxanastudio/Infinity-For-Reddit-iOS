//
//  UserListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-22.
//

import SwiftUI

struct UserListingView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    
    @StateObject var userListingViewModel: UserListingViewModel
    @State private var showSortTypeKindSheet: Bool = false
    @State private var navigationBarMenuKey: UUID?
    private let account: Account
    
    init(account: Account, query: String) {
        self.account = account
        
        _userListingViewModel = StateObject(
            wrappedValue: UserListingViewModel(
                query: query,
                userListingRepository: UserListingRepository()
            )
        )
    }
    
    var body: some View {
        Group {
            if userListingViewModel.isInitialLoading || userListingViewModel.isInitialLoad {
                ProgressIndicator()
            } else if userListingViewModel.users.isEmpty {
                Text("No users")
            } else {
                List {
                    ForEach(userListingViewModel.users, id: \.id) { user in
                        HStack {
                            CustomWebImage(
                                user.iconImg == nil || user.iconImg.isEmpty ? "" : user.subreddit?.iconImg,
                                width: 40,
                                height: 40,
                                circleClipped: true,
                                handleImageTapGesture: false,
                                fallbackView: {
                                    SwiftUI.Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                }
                            )
                            
                            Spacer()
                                .frame(width: 24)
                            
                            Text("u/" + user.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .primaryText()
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .listPlainItem()
                        .onTapGesture {
                            navigationManager.path.append(AppNavigation.userDetails(username: user.name))
                        }
                    }
                    if userListingViewModel.hasMorePages {
                        ProgressIndicator()
                            .task {
                                await userListingViewModel.loadUsers()
                            }
                            .listPlainItem()
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .themedList()
            }
        }
        .onChange(of: colorScheme) {
            //print(colorScheme == .dark)
        }
        .task(id: userListingViewModel.loadUsersTaskId) {
            await userListingViewModel.initialLoadUsers()
        }
        .refreshable {
            await userListingViewModel.refreshUsersWithContinuation()
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Refresh") {
                    userListingViewModel.refreshUsers()
                },
                
                NavigationBarMenuItem(title: "Sort") {
                    showSortTypeKindSheet = true
                }
            ])
        }
        .onDisappear {
            guard let navigationBarMenuKey else { return }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
        .sheet(isPresented: $showSortTypeKindSheet) {
            SortTypeKindSheet(
                sortTypeKindSource: OtherSortTypeKindSource.userListing,
                currentSortTypeKind: userListingViewModel.sortType
            ) { sortTypeKind in
                userListingViewModel.changeSortTypeKind(sortTypeKind)
            }
            .presentationDetents([.medium, .large])
        }
    }
}
