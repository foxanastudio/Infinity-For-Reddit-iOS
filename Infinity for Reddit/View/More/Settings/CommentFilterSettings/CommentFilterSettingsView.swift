//
// CommentFilterSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct CommentFilterSettingsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    
    @StateObject var commentFilterViewModel: CommentFilterViewModel
    @State private var selectedCommentFilter: CommentFilter?
    @State private var navigationBarMenuKey: UUID?
    
    @State private var showCommentFilterOptionSheet: Bool = false
    @State private var showSelectFieldToAddToCommentFitlerSheet: Bool = false
    
    init(commentToBeAdded: Comment?) {
        _commentFilterViewModel = StateObject(
            wrappedValue: CommentFilterViewModel(
                commentToBeAdded: commentToBeAdded,
                commentFilterRepository: CommentFilterRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            if commentFilterViewModel.commentFilters.isEmpty {
                VStack(spacing: 0) {
                    InfoPreference(title: "Restart the app to see the changes", icon: "info.circle")
                    
                    VStack(alignment: .center, spacing: 8) {
                        Spacer()
                        
                        SwiftUI.Image(systemName: "plus.circle")
                            .primaryIcon()
                        
                        Text("Start by creating a comment filter")
                            .primaryIcon()
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if commentFilterViewModel.commentToBeAdded == nil {
                            navigationManager.append(SettingsViewNavigation.createOrEditCommentFilter())
                        } else {
                            showSelectFieldToAddToCommentFitlerSheet = true
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    InfoPreference(title: "Restart the app to see the changes", icon: "info.circle")
                        .listPlainItemNoInsets()
                    
                    ForEach(commentFilterViewModel.commentFilters, id: \.identityForView) { commentFilter in
                        CommentFilterItemView(commentFilter: commentFilter) {
                            selectedCommentFilter = commentFilter
                            showCommentFilterOptionSheet = true
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                commentFilterViewModel.deleteCommentFilter(id: commentFilter.id ?? -1)
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
        .addTitleToInlineNavigationBar("Comment Filter")
        .toolbar {
            Button("", systemImage: "plus") {
                if commentFilterViewModel.commentToBeAdded == nil {
                    navigationManager.append(SettingsViewNavigation.createOrEditCommentFilter())
                } else {
                    showSelectFieldToAddToCommentFitlerSheet = true
                }
            }
        }
        .wrapContentSheet(isPresented: $showCommentFilterOptionSheet) {
            PostOrCommentFilterOptionSheet(
                onEditSelected: {
                    if let commentFilter = selectedCommentFilter {
                        if commentFilterViewModel.commentToBeAdded == nil {
                            navigationManager.append(SettingsViewNavigation.createOrEditCommentFilter(commentFilter: commentFilter))
                        } else {
                            showSelectFieldToAddToCommentFitlerSheet = true
                        }
                    }
                }, onApplyToSelected: {
                    if let commentFilter = selectedCommentFilter, let id = commentFilter.id {
                        navigationManager.append(SettingsViewNavigation.commentFilterUsageListing(commentFilterId: id))
                    }
                }, onDeleteSelected: {
                    if let commentFilter = selectedCommentFilter, let id = commentFilter.id {
                        commentFilterViewModel.deleteCommentFilter(id: id)
                    }
                }
            )
        }
        .wrapContentSheet(isPresented: $showSelectFieldToAddToCommentFitlerSheet) {
            if let commentToBeAdded = commentFilterViewModel.commentToBeAdded {
                SelectFieldToAddToCommentFilterSheet { selectedFieldsToAddToCommentFilter in
                    navigationManager.append(
                        SettingsViewNavigation.createOrEditCommentFilter(
                            commentFilter: selectedCommentFilter, commentToBeAdded: commentToBeAdded, selectedFieldsToAddToCommentFilter: selectedFieldsToAddToCommentFilter
                        )
                    )
                }
            }
        }
    }
}
