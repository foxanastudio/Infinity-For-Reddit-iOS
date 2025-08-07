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
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @StateObject var postFilterViewModel: PostFilterViewModel
    @State private var selectedPostFilter: PostFilter?
    @State private var navigationBarMenuKey: UUID?
    
    @State private var showPostFilterOptionSheet: Bool = false
    
    init() {
        _postFilterViewModel = StateObject(
            wrappedValue: PostFilterViewModel(
                postFilterRepository: PostFilterRepository()
            )
        )
    }
    
    var body: some View {
        Group {
            if postFilterViewModel.postFilters.isEmpty {
                VStack(spacing: 0) {
                    InfoPreference(title: "Restart the app to see the changes", iconUrl: "info.circle")
                    
                    Divider()
                    
                    VStack(alignment: .center, spacing: 8) {
                        Spacer()
                        
                        SwiftUI.Image(systemName: "plus.circle")
                            .primaryIcon()
                        
                        Text("Start by creating a post filter")
                            .primaryIcon()
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigationManager.path.append(SettingsViewNavigation.createOrEditPostFilter())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    InfoPreference(title: "Restart the app to see the changes", iconUrl: "info.circle")
                        .listPlainItemNoInsets()
                    
                    Divider()
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
                    }
                }
                .themedList()
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Post Filter")
        .toolbar {
            Button("", systemImage: "plus") {
                navigationManager.path.append(SettingsViewNavigation.createOrEditPostFilter())
            }
        }
        .sheet(isPresented: $showPostFilterOptionSheet) {
            PostOrCommentFilterOptionSheet(
                onEditSelected: {
                    if let postFilter = selectedPostFilter {
                        navigationManager.path.append(SettingsViewNavigation.createOrEditPostFilter(postFilter: postFilter))
                    }
                }, onApplyToSelected: {
                    if let postFilter = selectedPostFilter, let id = postFilter.id {
                        navigationManager.path.append(SettingsViewNavigation.postFilterUsageListing(postFilterId: id))
                    }
                }, onDeleteSelected: {
                    if let postFilter = selectedPostFilter, let id = postFilter.id {
                        postFilterViewModel.deletePostFilter(id: id)
                    }
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
}
