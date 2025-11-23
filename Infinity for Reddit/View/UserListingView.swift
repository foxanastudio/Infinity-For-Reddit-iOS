//
//  UserListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-22.
//

import SwiftUI

struct UserListingView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @ObservedObject private var userListingViewModel: UserListingViewModel
    @State private var showSortTypeKindSheet: Bool = false
    @State private var navigationBarMenuKey: UUID?
    private let account: Account
    private let iconSize: CGFloat = 28
    
    init(account: Account, userListingViewModel: UserListingViewModel) {
        self.account = account
        self.userListingViewModel = userListingViewModel
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
                        HStack(spacing: 0) {
                            CustomWebImage(
                                user.iconUrl,
                                width: iconSize,
                                height: iconSize,
                                circleClipped: true,
                                handleImageTapGesture: false,
                                fallbackView: {
                                    InitialLetterAvatarImageFallbackView(name: user.name, size: iconSize)
                                }
                            )
                            
                            Spacer()
                                .frame(width: 24)
                            
                            Text("u/" + user.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .primaryText()
                            
                            Spacer()
                            
                            if userListingViewModel.thingSelectionMode.isMultiSelection {
                                SwiftUI.Image(systemName: isSelected(user) ? "checkmark.square" : "square")
                                    .primaryIcon()
                            }
                        }
                        .listPlainItemNoInsets()
                        .padding(16)
                        .background(isSelected(user) ? Color(hex: customThemeViewModel.currentCustomTheme.filledCardViewBackgroundColor) : Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            switch userListingViewModel.thingSelectionMode {
                            case .noSelection:
                                navigationManager.append(AppNavigation.userDetails(username: user.name))
                            case .thingSelection(let onSelectThing):
                                onSelectThing(.user(user.toUserData()))
                                dismiss()
                            case .subredditAndUserMultiSelection:
                                userListingViewModel.toggleSelection(user: user)
                            }
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
        .wrapContentSheet(isPresented: $showSortTypeKindSheet) {
            SortTypeKindSheet(
                sortTypeKindSource: OtherSortTypeKindSource.userListing,
                currentSortTypeKind: userListingViewModel.sortType
            ) { sortTypeKind in
                userListingViewModel.changeSortTypeKind(sortTypeKind)
            }
        }
    }
    
    func isSelected(_ user: User) -> Bool {
        return userListingViewModel.selectedUsers.index(id: user.id) != nil
    }
}
