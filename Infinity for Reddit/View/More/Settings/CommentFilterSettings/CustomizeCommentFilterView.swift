//
//  CustomizeCommentFilterView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-06.
//

import SwiftUI
import Swinject
import Combine

struct CustomizeCommentFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @StateObject private var customizeCommentFilterViewModel: CustomizeCommentFilterViewModel
    
    init(_ commentFilter: CommentFilter?) {
        _customizeCommentFilterViewModel = StateObject(
            wrappedValue: CustomizeCommentFilterViewModel(
                commentFilter: commentFilter,
                customizeCommentFilterRepository: CustomizeCommentFilterRepository()
            )
        )
    }
    
    var body: some View {
        List {
            FilledCardView {
                VStack(spacing: 16) {
                    Text("The name should be unique.")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Comment Filter Name", text: $customizeCommentFilterViewModel.name)
                }
                .padding(16)
            }
            .listPlainItemNoInsets()
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            FilledCardView {
                VStack(spacing: 16) {
                    Text("Comments will be filtered out if they contain the following keywords.")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Title: excludes keywords (key1,key2)", text: $customizeCommentFilterViewModel.excludesKeywords)
                        .lineLimit(1...5)
                }
                .padding(16)
            }
            .listPlainItemNoInsets()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            FilledCardView {
                VStack(spacing: 16) {
                    Text("Comments submitted by the following users will be filtered out.")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        CustomTextField("E.g. Hostilenemy,random", text: $customizeCommentFilterViewModel.excludeUsers)
                            .lineLimit(1...5)
                        
                        Button(action: {}) {
                            SwiftUI.Image(systemName: "plus")
                                .primaryIcon()
                        }
                        .padding(.leading, 16)
                    }
                }
                .padding(16)
            }
            .listPlainItemNoInsets()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            FilledCardView {
                VStack(spacing: 16) {
                    Text("Comments that have a score lower than the following value will be filtered out (-1 means no restriction).")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Min vote (-1: no restriction)", text: $customizeCommentFilterViewModel.minVoteString, singleLine: true)
                        .onReceive(Just(customizeCommentFilterViewModel.minVoteString)) { newValue in
                            var sanitized = ""
                            if newValue.hasPrefix("-") {
                                sanitized = "-"
                            }
                            
                            sanitized += newValue
                                .dropFirst(sanitized == "-" ? 1 : 0)
                                .filter { $0.isNumber }
                            
                            if sanitized != newValue {
                                customizeCommentFilterViewModel.minVoteString = sanitized
                            }
                            
                            let newMinVote = Int(sanitized) ?? -1
                            if customizeCommentFilterViewModel.minVote != newMinVote {
                                customizeCommentFilterViewModel.minVote = newMinVote
                            }
                        }
                    
                    Text("Comments that have a score higher than the following value will be filtered out (-1 means no restriction).")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Max vote (-1: no restriction)", text: $customizeCommentFilterViewModel.maxVoteString, singleLine: true)
                        .onReceive(Just(customizeCommentFilterViewModel.maxVoteString)) { newValue in
                            var sanitized = ""
                            if newValue.hasPrefix("-") {
                                sanitized = "-"
                            }
                            
                            sanitized += newValue
                                .dropFirst(sanitized == "-" ? 1 : 0)
                                .filter { $0.isNumber }
                            
                            if sanitized != newValue {
                                customizeCommentFilterViewModel.maxVoteString = sanitized
                            }
                            
                            let newMaxVote = Int(sanitized) ?? -1
                            if customizeCommentFilterViewModel.maxVote != newMaxVote {
                                customizeCommentFilterViewModel.maxVote = newMaxVote
                            }
                        }
                }
                .padding(16)
            }
            .listPlainItemNoInsets()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .themedList()
        .themedNavigationBar()
        .toolbar {
            Button("", systemImage: "tray.and.arrow.down.fill") {
                if customizeCommentFilterViewModel.saveCommentFilter() {
                    dismiss()
                } else {
                    // TODO handle exception
                }
            }
        }
    }
}
