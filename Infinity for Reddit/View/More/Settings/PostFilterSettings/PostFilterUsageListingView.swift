//
//  PostFilterUsageListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-03.
//

import SwiftUI

struct PostFilterUsageListingView: View {
    @StateObject private var postFilterUsageViewModel: PostFilterUsageListingViewModel
    @State private var showPostFilterUsageSheet: Bool = false
    
    init(postFilterId: Int) {
        _postFilterUsageViewModel = StateObject(
            wrappedValue: PostFilterUsageListingViewModel(
                postFilterId: postFilterId,
                postFilterUsageRepository: PostFilterUsageListingRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            if postFilterUsageViewModel.postFilterUsages.isEmpty {
                VStack(spacing: 0) {
                    VStack(alignment: .center, spacing: 8) {
                        Spacer()
                        
                        SwiftUI.Image(systemName: "plus.circle")
                            .primaryIcon()
                        
                        Text("Start by applying your post filter somewhere")
                            .primaryIcon()
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showPostFilterUsageSheet = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(postFilterUsageViewModel.postFilterUsages, id: \.self) { postFilterUsage in
                        TouchRipple(action: {
                            
                        }) {
                            VStack {
                                Text(postFilterUsage.description)
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .contentShape(Rectangle())
                            .padding(16)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                postFilterUsageViewModel.deletePostFilterUsage(postFilterUsage)
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
        .addTitleToInlineNavigationBar("Post Filter Usage")
        .toolbar {
            Button("", systemImage: "plus") {
                showPostFilterUsageSheet = true
            }
        }
        .wrapContentSheet(isPresented: $showPostFilterUsageSheet) {
            PostFilterUsageSheet { usageType, nameOfUsage in
                postFilterUsageViewModel.savePostFilterUsage(usageType: usageType, nameOfUsage: nameOfUsage)
            }
        }
    }
}
