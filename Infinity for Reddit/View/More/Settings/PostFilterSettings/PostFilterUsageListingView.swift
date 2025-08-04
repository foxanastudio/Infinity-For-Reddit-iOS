//
//  PostFilterUsageListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-03.
//

import SwiftUI

struct PostFilterUsageListingView: View {
    @StateObject private var postFilterUsageViewModel: PostFilterUsageViewModel
    
    init(postFilterId: Int) {
        _postFilterUsageViewModel = StateObject(
            wrappedValue: PostFilterUsageViewModel(
                postFilterId: postFilterId,
                postFilterUsageRepository: PostFilterUsageRepository()
            )
        )
    }
    
    var body: some View {
        Group {
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
                
            }
        }
    }
}
