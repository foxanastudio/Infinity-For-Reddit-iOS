//
//  CustomizePostFilterView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-07.
//

import SwiftUI
import Swinject
import Combine

struct CustomizePostFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @StateObject private var customizePostFilterViewModel: CustomizePostFilterViewModel
    
    @FocusState private var focusedField: FieldType?
    
    private let showInSheet: Bool
    private let onApplyPostFilter: ((PostFilter) -> Void)?
    
    init(_ postFilter: PostFilter?, showInSheet: Bool = false, onApplyPostFilter: ((PostFilter) -> Void)? = nil) {
        self.showInSheet = showInSheet
        self.onApplyPostFilter = onApplyPostFilter
        _customizePostFilterViewModel = StateObject(
            wrappedValue: CustomizePostFilterViewModel(
                postFilter: postFilter,
                customizePostFilterRepository: CustomizePostFilterRepository()
            )
        )
    }
    
    init(_ postFilter: PostFilter?, postToBeAdded: Post?, subredditToBeAdded: String?, userToBeAdded: String?, selectedFieldsToAddToPostFilter: [SelectedFieldToAddToPostFilter]?) {
        self.showInSheet = false
        self.onApplyPostFilter = nil
        _customizePostFilterViewModel = StateObject(
            wrappedValue: CustomizePostFilterViewModel(
                postFilter: postFilter,
                postToBeAdded: postToBeAdded,
                subredditToBeAdded: subredditToBeAdded,
                userToBeAdded: userToBeAdded,
                selectedFieldsToAddToPostFilter: selectedFieldsToAddToPostFilter,
                customizePostFilterRepository: CustomizePostFilterRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            VStack(spacing: 0) {
                if showInSheet {
                    HStack(spacing: 0) {
                        Text("Cancel")
                            .neutralTextButton()
                            .onTapGesture {
                                dismiss()
                            }
                        
                        Spacer()
                        
                        if let onApplyPostFilter = onApplyPostFilter {
                            Text("Apply")
                                .positiveTextButton()
                                .padding(.trailing, 16)
                                .onTapGesture {
                                    onApplyPostFilter(customizePostFilterViewModel.getPostFilter())
                                    dismiss()
                                }
                        }
                        
                        Text("Save")
                            .positiveTextButton()
                            .onTapGesture {
                                customizePostFilterViewModel.savePostFilter()
                            }
                    }
                    .padding(16)
                }
                
                ScrollViewReader { proxy in
                    ScrollView {
                        FilledCardView {
                            VStack(spacing: 16) {
                                Text("The name should be unique.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Post Filter Name",
                                                text: $customizePostFilterViewModel.name,
                                                singleLine: true,
                                                fieldType: .postFilterName,
                                                focusedField: $focusedField)
                                .submitLabel(.done)
                                .id(FieldType.postFilterName)
                            }
                            .padding(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        
                        FilledCardView {
                            VStack(spacing: 0) {
                                Text("To see certain types of posts, please turn on the switch corresponding to the types.")
                                    .primaryText()
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                    .padding(.bottom, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                TogglePreference(isEnabled: $customizePostFilterViewModel.showText, title: "Text", icon: "text.page")
                                
                                TogglePreference(isEnabled: $customizePostFilterViewModel.showLink, title: "Link", icon: "link")
                                
                                TogglePreference(isEnabled: $customizePostFilterViewModel.showImage, title: "Image", icon: "photo")
                                
                                TogglePreference(isEnabled: $customizePostFilterViewModel.showGif, title: "Gif", icon: "photo")
                                
                                TogglePreference(isEnabled: $customizePostFilterViewModel.showVideo, title: "Video", icon: "video")
                                
                                TogglePreference(isEnabled: $customizePostFilterViewModel.showGallery, title: "Gallery", icon: "square.stack")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        FilledCardView {
                            VStack(spacing: 0) {
                                Text("To only see sensitive or spoiler posts, please turn on the corresponding switch.")
                                    .primaryText()
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                    .padding(.bottom, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                TogglePreference(isEnabled: $customizePostFilterViewModel.onlySensitive, title: "Only Sensitive Content", icon: "figure.child.and.lock")
                                
                                TogglePreference(isEnabled: $customizePostFilterViewModel.onlySpoiler, title: "Only Spoiler", icon: "exclamationmark.triangle.fill")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        FilledCardView {
                            VStack(spacing: 16) {
                                Text("Posts will be filtered out if they contain the following keywords in their title")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Title: excludes keywords (key1,key2)",
                                                text: $customizePostFilterViewModel.excludesKeywords,
                                                fieldType: .excludeKeywords,
                                                focusedField: $focusedField)
                                    .lineLimit(1...5)
                                    .id(FieldType.excludeKeywords)
                                
                                Text("Posts will be filtered out if they do not contain the following keywords in their title.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Title: contains keywords (key1,key2)",
                                                text: $customizePostFilterViewModel.containsKeywords,
                                                fieldType: .containKeywords,
                                                focusedField: $focusedField)
                                    .lineLimit(1...5)
                                    .id(FieldType.containKeywords)
                            }
                            .padding(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        FilledCardView {
                            VStack(spacing: 16) {
                                Text("Posts will be filtered out if their title matches the following regular expression.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Title: excludes regex",
                                                text: $customizePostFilterViewModel.excludesRegex,
                                                fieldType: .titleExcludeRegex,
                                                focusedField: $focusedField)
                                    .lineLimit(1...5)
                                    .id(FieldType.titleExcludeRegex)
                                
                                Text("Posts will be filtered out if their title does not match the following regular expression.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Title: contains regex",
                                                text: $customizePostFilterViewModel.containsRegex,
                                                fieldType: .titleContainRegex,
                                                focusedField: $focusedField)
                                    .lineLimit(1...5)
                                    .id(FieldType.titleContainRegex)
                            }
                            .padding(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        FilledCardView {
                            VStack(spacing: 16) {
                                Text("Posts from the following subreddits will be filtered out.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 0) {
                                    CustomTextField("E.g. funny,AskReddit",
                                                    text: $customizePostFilterViewModel.excludeSubreddits,
                                                    fieldType: .excludeSubreddits,
                                                    focusedField: $focusedField)
                                        .lineLimit(1...5)
                                        .id(FieldType.excludeSubreddits)
                                    
                                    Button(action: {}) {
                                        SwiftUI.Image(systemName: "plus")
                                            .primaryIcon()
                                    }
                                    .padding(.leading, 16)
                                }
                                
                                Text("Posts submitted by the following users will be filtered out.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {
                                    CustomTextField("E.g. Hostilenemy,random",
                                                    text: $customizePostFilterViewModel.excludeUsers,
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
                                Text("Posts that have the following flairs will be filtered out.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Exclude flairs (e.g., flair1,flair2)",
                                                text: $customizePostFilterViewModel.excludeFlairs,
                                                fieldType: .excludeFlairs,
                                                focusedField: $focusedField)
                                    .lineLimit(1...5)
                                    .id(FieldType.excludeFlairs)
                                
                                Text("Posts that do not have the following flairs will be filtered out.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Contain flairs (e.g., flair1,flair2)",
                                                text: $customizePostFilterViewModel.containFlairs,
                                                fieldType: .containFlairs,
                                                focusedField: $focusedField)
                                    .lineLimit(1...5)
                                    .id(FieldType.containFlairs)
                            }
                            .padding(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        FilledCardView {
                            VStack(spacing: 16) {
                                Text("Link posts that have the following urls will be filtered out.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Exclude domains",
                                                text: $customizePostFilterViewModel.excludeDomains,
                                                fieldType: .excludeDomains,
                                                focusedField: $focusedField)
                                    .lineLimit(1...5)
                                    .id(FieldType.excludeDomains)
                                
                                Text("Link posts that do not have the following urls will be filtered out.")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Contain domains",
                                                text: $customizePostFilterViewModel.containDomains,
                                                fieldType: .containDomains,
                                                focusedField: $focusedField)
                                    .lineLimit(1...5)
                                    .id(FieldType.containDomains)
                            }
                            .padding(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        FilledCardView {
                            VStack(spacing: 16) {
                                Text("Posts that have a score lower than the following value will be filtered out (-1 means no restriction).")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Min vote (-1: no restriction)",
                                                text: $customizePostFilterViewModel.minVoteString,
                                                singleLine: true,
                                                fieldType: .minVotes,
                                                focusedField: $focusedField)
                                .submitLabel(.done)
                                .id(FieldType.minVotes)
                                .onReceive(Just(customizePostFilterViewModel.minVoteString)) { newValue in
                                    var sanitized = ""
                                    if newValue.hasPrefix("-") {
                                        sanitized = "-"
                                    }
                                    
                                    sanitized += newValue
                                        .dropFirst(sanitized == "-" ? 1 : 0)
                                        .filter { $0.isNumber }
                                    
                                    if sanitized != newValue {
                                        customizePostFilterViewModel.minVoteString = sanitized
                                    }
                                    
                                    let newMinVote = Int(sanitized) ?? -1
                                    if customizePostFilterViewModel.minVote != newMinVote {
                                        customizePostFilterViewModel.minVote = newMinVote
                                    }
                                }
                                    
                                
                                Text("Posts that have a score higher than the following value will be filtered out (-1 means no restriction).")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Max vote (-1: no restriction)",
                                                text: $customizePostFilterViewModel.maxVoteString,
                                                singleLine: true,
                                                fieldType: .maxVotes,
                                                focusedField: $focusedField)
                                .submitLabel(.done)
                                .id(FieldType.maxVotes)
                                .onReceive(Just(customizePostFilterViewModel.maxVoteString)) { newValue in
                                    var sanitized = ""
                                    if newValue.hasPrefix("-") {
                                        sanitized = "-"
                                    }
                                    
                                    sanitized += newValue
                                        .dropFirst(sanitized == "-" ? 1 : 0)
                                        .filter { $0.isNumber }
                                    
                                    if sanitized != newValue {
                                        customizePostFilterViewModel.maxVoteString = sanitized
                                    }
                                    
                                    let newMaxVote = Int(sanitized) ?? -1
                                    if customizePostFilterViewModel.maxVote != newMaxVote {
                                        customizePostFilterViewModel.maxVote = newMaxVote
                                    }
                                }
                                    
                            }
                            .padding(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        FilledCardView {
                            VStack(spacing: 16) {
                                Text("Posts will be filtered out if the number of their comments is less than the following value. (-1 means no restriction).")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Min comments (-1: no restriction)",
                                                text: $customizePostFilterViewModel.minCommentsString,
                                                singleLine: true,
                                                fieldType: .minComments,
                                                focusedField: $focusedField)
                                .submitLabel(.done)
                                .id(FieldType.minComments)
                                .onReceive(Just(customizePostFilterViewModel.minCommentsString)) { newValue in
                                    var sanitized = ""
                                    if newValue.hasPrefix("-") {
                                        sanitized = "-"
                                    }
                                    
                                    sanitized += newValue
                                        .dropFirst(sanitized == "-" ? 1 : 0)
                                        .filter { $0.isNumber }
                                    
                                    if sanitized != newValue {
                                        customizePostFilterViewModel.minCommentsString = sanitized
                                    }
                                    
                                    let newMinComments = Int(sanitized) ?? -1
                                    if customizePostFilterViewModel.minComments != newMinComments {
                                        customizePostFilterViewModel.minComments = newMinComments
                                    }
                                }
                                    
                                
                                Text("Posts will be filtered out if the number of their comments is larger than the following value. (-1 means no restriction).")
                                    .primaryText()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CustomTextField("Max comments (-1: no restriction)",
                                                text: $customizePostFilterViewModel.maxCommentsString,
                                                singleLine: true,
                                                fieldType: .maxComments,
                                                focusedField: $focusedField)
                                .submitLabel(.done)
                                .id(FieldType.maxComments)
                                .onReceive(Just(customizePostFilterViewModel.maxCommentsString)) { newValue in
                                    var sanitized = ""
                                    if newValue.hasPrefix("-") {
                                        sanitized = "-"
                                    }
                                    
                                    sanitized += newValue
                                        .dropFirst(sanitized == "-" ? 1 : 0)
                                        .filter { $0.isNumber }
                                    
                                    if sanitized != newValue {
                                        customizePostFilterViewModel.maxCommentsString = sanitized
                                    }
                                    
                                    let newMaxComments = Int(sanitized) ?? -1
                                    if customizePostFilterViewModel.maxComments != newMaxComments {
                                        customizePostFilterViewModel.maxComments = newMaxComments
                                    }
                                }
                                    
                            }
                            .padding(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
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
        .applyIf(!showInSheet) {
            $0.toolbar {
                if let onApplyPostFilter = onApplyPostFilter {
                    Button("", systemImage: "checkmark.circle") {
                        onApplyPostFilter(customizePostFilterViewModel.getPostFilter())
                    }
                }
                
                Button("", systemImage: "tray.and.arrow.down.fill") {
                    customizePostFilterViewModel.savePostFilter()
                }
            }
        }
        .applyIf(showInSheet) {
            $0.interactiveDismissDisabled(true)
        }
        .onChange(of: customizePostFilterViewModel.savedPostFilterFlag) {
            onApplyPostFilter?(customizePostFilterViewModel.getPostFilter())
            dismiss()
        }
    }
    
    private enum FieldType: Hashable {
        case postFilterName, excludeKeywords, containKeywords, titleExcludeRegex, titleContainRegex, excludeSubreddits, excludeUsers,
             excludeFlairs, containFlairs, excludeDomains, containDomains, minVotes, maxVotes, minComments, maxComments
    }
}
