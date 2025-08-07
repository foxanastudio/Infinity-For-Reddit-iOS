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
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @StateObject var commentFilterViewModel: CommentFilterViewModel
    @State private var selectedCommentFilter: CommentFilter?
    @State private var navigationBarMenuKey: UUID?
    
    @State private var showCommentFilterOptionSheet: Bool = false
    
    init() {
        _commentFilterViewModel = StateObject(
            wrappedValue: .init(
                commentFilterRepository: CommentFilterRepository()
            )
        )
    }
    
    var body: some View {
        Group {
            if commentFilterViewModel.commentFilters.isEmpty {
                VStack(spacing: 0) {
                    InfoPreference(title: "Restart the app to see the changes", iconUrl: "info.circle")
                    
                    Divider()
                    
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
                        navigationManager.path.append(SettingsViewNavigation.createOrEditCommentFilter())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    InfoPreference(title: "Restart the app to see the changes", iconUrl: "info.circle")
                        .listPlainItemNoInsets()
                    
                    Divider()
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
                    }
                }
                .themedList()
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Comment Filter")
        .toolbar {
            Button("", systemImage: "plus") {
                navigationManager.path.append(SettingsViewNavigation.createOrEditCommentFilter())
            }
        }
        .sheet(isPresented: $showCommentFilterOptionSheet) {
            PostOrCommentFilterOptionSheet(
                onEditSelected: {
                    if let commentFilter = selectedCommentFilter {
                        navigationManager.path.append(SettingsViewNavigation.createOrEditCommentFilter(commentFilter: commentFilter))
                    }
                }, onApplyToSelected: {
                    if let commentFilter = selectedCommentFilter, let id = commentFilter.id {
                        navigationManager.path.append(SettingsViewNavigation.commentFilterUsageListing(commentFilterId: id))
                    }
                }, onDeleteSelected: {
                    if let commentFilter = selectedCommentFilter, let id = commentFilter.id {
                        commentFilterViewModel.deleteCommentFilter(id: id)
                    }
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
}
