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
    private let isPresented: Bool
    private let iconSize: CGFloat = 28
    
    init(account: Account, userListingViewModel: UserListingViewModel, isPresented: Bool = true) {
        self.account = account
        self.userListingViewModel = userListingViewModel
        self.isPresented = isPresented
    }
    
    var body: some View {
        RootView {
            if userListingViewModel.users.isEmpty {
                ZStack {
                    if userListingViewModel.isInitialLoading {
                        ProgressIndicator()
                    } else if userListingViewModel.isInitialLoad, let error = userListingViewModel.error {
                        Text("Unable to load users. Tap to retry. Error: \(error.localizedDescription)")
                            .primaryText()
                            .padding(16)
                            .onTapGesture {
                                userListingViewModel.refreshUsers()
                            }
                    } else {
                        Text("No users")
                            .primaryText()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                            case .subredditMultiSelection:
                                // Shouldn't happen
                                break
                            case .userMultiSelection:
                                userListingViewModel.toggleSelection(user: user)
                            }
                        }
                    }
                    
                    if userListingViewModel.hasMorePages {
                        HStack {
                            ProgressIndicator()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .task {
                            guard !userListingViewModel.isPullToRefreshing else {
                                return
                            }
                            await userListingViewModel.loadUsers()
                        }
                        .listPlainItem()
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .themedList()
                .showErrorUsingSnackbar(userListingViewModel.$error)
            }
        }
        .task(id: taskKey) {
            guard isPresented else {
                return
            }
            
            await userListingViewModel.initialLoadUsers()
        }
        .refreshable {
            await userListingViewModel.refreshUsersWithContinuation()
        }
        .onAppear {
            setUpMenu()
        }
        .onDisappear {
            guard let navigationBarMenuKey else {
                return
            }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
        .onChange(of: isPresented) { _, newValue in
            setUpMenu()
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
    
    private var taskKey: LoadUsersTaskKey {
        LoadUsersTaskKey(
            loadUsersTaskId: userListingViewModel.loadUsersTaskId,
            isPresented: isPresented
        )
    }
    
    private func setUpMenu() {
        if isPresented {
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
        } else {
            guard let navigationBarMenuKey else {
                return
            }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
    }
    
    private func isSelected(_ user: User) -> Bool {
        return userListingViewModel.selectedUsers.index(id: user.id) != nil
        || userListingViewModel.selectedSubscribedUsers.index(id: user.id) != nil
        || userListingViewModel.selectedUserData.index(id: user.id) != nil
        || userListingViewModel.selectedUserSubredditsInCustomFeed.index(id: "u_\(user.name)") != nil
    }
    
    struct LoadUsersTaskKey: Hashable {
        let loadUsersTaskId: UUID
        let isPresented: Bool
    }
}
