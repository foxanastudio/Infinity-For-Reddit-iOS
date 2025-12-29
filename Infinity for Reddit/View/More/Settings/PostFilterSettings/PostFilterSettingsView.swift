//
// PostFilterSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct PostFilterSettingsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    
    @StateObject var postFilterViewModel: PostFilterViewModel
    @State private var selectedPostFilter: PostFilter?
    @State private var navigationBarMenuKey: UUID?
    @State private var showPostFilterOptionSheet: Bool = false
    @State private var showSelectFieldToAddToPostFitlerSheet: Bool = false
    
    init(postToBeAdded: Post?, subredditToBeAdded: String?, userToBeAdded: String?) {
        _postFilterViewModel = StateObject(
            wrappedValue: PostFilterViewModel(
                postToBeAdded: postToBeAdded,
                subredditToBeAdded: subredditToBeAdded,
                userToBeAdded: userToBeAdded,
                postFilterRepository: PostFilterRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            if postFilterViewModel.postFilters.isEmpty {
                VStack(spacing: 0) {
                    InfoPreference(title: "Restart the app to see the changes", icon: "info.circle")
                    
                    VStack(alignment: .center, spacing: 8) {
                        Spacer()
                        
                        SwiftUI.Image(systemName: "plus.circle")
                            .primaryIcon()
                        
                        Text("Start by creating a post filter")
                            .primaryText()
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if postFilterViewModel.postToBeAdded == nil && postFilterViewModel.subredditToBeAdded == nil && postFilterViewModel.userToBeAdded == nil {
                            navigationManager.append(SettingsViewNavigation.createOrEditPostFilter())
                        } else {
                            showSelectFieldToAddToPostFitlerSheet = true
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    InfoPreference(title: "Restart the app to see the changes", icon: "info.circle")
                        .listPlainItemNoInsets()
                    
                    ForEach(postFilterViewModel.postFilters, id: \.identityForView) { postFilter in
                        PostFilterItemView(postFilter: postFilter) {
                            selectedPostFilter = postFilter
                            showPostFilterOptionSheet = true
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                postFilterViewModel.deletePostFilter(id: postFilter.id ?? -1)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                        .listPlainItemNoInsets()
                        .limitedWidthListItem()
                    }
                }
                .themedList()
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Post Filter")
        .toolbar {
            Button("", systemImage: "plus") {
                if postFilterViewModel.postToBeAdded == nil && postFilterViewModel.subredditToBeAdded == nil && postFilterViewModel.userToBeAdded == nil {
                    navigationManager.append(SettingsViewNavigation.createOrEditPostFilter())
                } else {
                    showSelectFieldToAddToPostFitlerSheet = true
                }
            }
        }
        .wrapContentSheet(isPresented: $showPostFilterOptionSheet) {
            PostOrCommentFilterOptionSheet(
                onEditSelected: {
                    if let postFilter = selectedPostFilter {
                        if postFilterViewModel.postToBeAdded == nil && postFilterViewModel.subredditToBeAdded == nil && postFilterViewModel.userToBeAdded == nil {
                            navigationManager.append(SettingsViewNavigation.createOrEditPostFilter(postFilter: postFilter))
                        } else {
                            showSelectFieldToAddToPostFitlerSheet = true
                        }
                    }
                }, onApplyToSelected: {
                    if let postFilter = selectedPostFilter, let id = postFilter.id {
                        navigationManager.append(SettingsViewNavigation.postFilterUsageListing(postFilterId: id))
                    }
                }, onDeleteSelected: {
                    if let postFilter = selectedPostFilter, let id = postFilter.id {
                        postFilterViewModel.deletePostFilter(id: id)
                    }
                }
            )
        }
        .wrapContentSheet(isPresented: $showSelectFieldToAddToPostFitlerSheet) {
            if let postToBeAdded = postFilterViewModel.postToBeAdded {
                SelectFieldToAddToPostFilterSheet { selectedFieldsToAddToPostFilter in
                    navigationManager.append(
                        SettingsViewNavigation.createOrEditPostFilter(
                            postFilter: selectedPostFilter, postToBeAdded: postToBeAdded, selectedFieldsToAddToPostFilter: selectedFieldsToAddToPostFilter
                        )
                    )
                }
            } else if let subredditToBeAdded = postFilterViewModel.subredditToBeAdded {
                SelectFieldToAddToPostFilterSheet(fields: [SelectedFieldToAddToPostFilter.excludeSubreddit, SelectedFieldToAddToPostFilter.containSubreddit]) { selectedFieldsToAddToPostFilter in
                    navigationManager.append(
                        SettingsViewNavigation.createOrEditPostFilter(
                            postFilter: selectedPostFilter, subredditToBeAdded: subredditToBeAdded, selectedFieldsToAddToPostFilter: selectedFieldsToAddToPostFilter
                        )
                    )
                }
            } else if let userToBeAdded = postFilterViewModel.userToBeAdded {
                SelectFieldToAddToPostFilterSheet(fields: [SelectedFieldToAddToPostFilter.excludeUser, SelectedFieldToAddToPostFilter.containUser]) { selectedFieldsToAddToPostFilter in
                    navigationManager.append(
                        SettingsViewNavigation.createOrEditPostFilter(
                            postFilter: selectedPostFilter, userToBeAdded: userToBeAdded, selectedFieldsToAddToPostFilter: selectedFieldsToAddToPostFilter
                        )
                    )
                }
            }
        }
    }
}
