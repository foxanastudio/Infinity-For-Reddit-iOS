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
    
    @FocusState private var focusedField: FieldType?
    
    init(_ commentFilter: CommentFilter?, commentToBeAdded: Comment? = nil, selectedFieldsToAddToCommentFilter: [SelectedFieldToAddToCommentFilter]? = nil) {
        _customizeCommentFilterViewModel = StateObject(
            wrappedValue: CustomizeCommentFilterViewModel(
                commentFilter: commentFilter,
                commentToBeAdded: commentToBeAdded,
                selectedFieldsToAddToCommentFilter: selectedFieldsToAddToCommentFilter,
                customizeCommentFilterRepository: CustomizeCommentFilterRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        FilledCardView {
                            VStack(spacing: 16) {
                                Text("The name should be unique.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Comment Filter Name",
                                                text: $customizeCommentFilterViewModel.name,
                                                singleLine: true,
                                                fieldType: .commentFilterName,
                                                focusedField: $focusedField)
                                .submitLabel(.done)
                                .id(FieldType.commentFilterName)
                            }
                            .padding(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        
                        FilledCardView {
                            VStack(spacing: 16) {
                                Text("Filtered out comments will be shown as the following selected option.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Picker("", selection: $customizeCommentFilterViewModel.displayMode) {
                                    Text("Remove")
                                        .primaryText()
                                        .tag(CommentFilter.DisplayMode.removeComment)
                                    
                                    Text("Fully collapse")
                                        .primaryText()
                                        .tag(CommentFilter.DisplayMode.collapseComment)
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        FilledCardView {
                            VStack(spacing: 16) {
                                Text("Comments will be filtered out if they contain the following keywords.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Title: excludes keywords (key1,key2)",
                                                text: $customizeCommentFilterViewModel.excludesKeywords,
                                                fieldType: .excludeKeywords,
                                                focusedField: $focusedField)
                                    .lineLimit(1...5)
                                    .id(FieldType.excludeKeywords)
                            }
                            .padding(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        FilledCardView {
                            VStack(spacing: 16) {
                                Text("Comments submitted by the following users will be filtered out.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {
                                    CustomTextField("E.g. Hostilenemy,random",
                                                    text: $customizeCommentFilterViewModel.excludeUsers,
                                                    fieldType: .excludeUsers,
                                                    focusedField: $focusedField)
                                        .lineLimit(1...5)
                                        .id(FieldType.excludeUsers)
                                    
                                    Button(action: {}) {
                                        SwiftUI.Image(systemName: "plus")
                                            .primaryIcon()
                                    }
                                    .padding(.leading, 16)
                                }
                            }
                            .padding(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        FilledCardView {
                            VStack(spacing: 16) {
                                Text("Comments that have a score lower than the following value will be filtered out (-1 means no restriction).")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Min vote (-1: no restriction)",
                                                text: $customizeCommentFilterViewModel.minVoteString,
                                                singleLine: true,
                                                fieldType: .minVotes,
                                                focusedField: $focusedField)
                                .submitLabel(.done)
                                .id(FieldType.minVotes)
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
                                
                                CustomTextField("Max vote (-1: no restriction)",
                                                text: $customizeCommentFilterViewModel.maxVoteString,
                                                singleLine: true,
                                                fieldType: .maxVotes,
                                                focusedField: $focusedField)
                                .submitLabel(.done)
                                .id(FieldType.maxVotes)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .themedList()
                    .onChange(of: focusedField) { oldField, newField in
                        guard let field = newField else { return }
                        DispatchQueue.main.async {
                            withAnimation {
                                proxy.scrollTo(field, anchor: .center)
                            }
                        }
                    }
                }
                
                KeyboardToolbar {
                    focusedField = nil
                }
            }
        }
        .themedNavigationBar()
        .toolbar {
            Button("", systemImage: "tray.and.arrow.down.fill") {
                customizeCommentFilterViewModel.saveCommentFilter()
            }
        }
        .onChange(of: customizeCommentFilterViewModel.savedCommentFilterFlag) {
            dismiss()
        }
    }
    
    private enum FieldType: Hashable {
        case commentFilterName, excludeKeywords, excludeUsers, minVotes, maxVotes
    }
}
