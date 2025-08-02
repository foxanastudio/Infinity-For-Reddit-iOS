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
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @StateObject var postFilterViewModel: PostFilterViewModel
    @State private var isCustomizePostFilter = false
    @State private var postFilterName: String? = nil
    @State private var navigationBarMenuKey: UUID?
    
    private let postFilterDao: PostFilterDao
    
    init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        postFilterDao = PostFilterDao(dbPool: resolvedDBPool)
        _postFilterViewModel = StateObject(
            wrappedValue: PostFilterViewModel(
                dbPool: resolvedDBPool
            )
        )
    }
    
    var body: some View {
        List {
            InfoPreference(title: "Restart the app to see the changes", iconUrl: "info.circle")
                .listPlainItemNoInsets()
            
            Divider()
                .listPlainItemNoInsets()
            
            if postFilterViewModel.postFilters.isEmpty {
                Text("No post filters found. Create a new one!")
                    .secondaryText()
                    .listPlainItemNoInsets()
            } else {
                ForEach(postFilterViewModel.postFilters, id: \.name) { filter in
                    TouchRipple(action: {
                        postFilterName = filter.name
                        isCustomizePostFilter = true
                    }) {
                        VStack {
                            Text(filter.name)
                                .primaryText()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .contentShape(Rectangle())
                        .padding(16)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            postFilterViewModel.deletePostFilter(filter.name)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                    .listPlainItemNoInsets()
                }
            }
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Post Filter")
        .toolbar {
            Button("", systemImage: "plus") {
                postFilterName = nil
                isCustomizePostFilter = true
            }
        }
        .sheet(isPresented: $isCustomizePostFilter) {
            CustomizePostFilterView($postFilterName)
        }
        .environmentObject(postFilterViewModel)
    }
}

