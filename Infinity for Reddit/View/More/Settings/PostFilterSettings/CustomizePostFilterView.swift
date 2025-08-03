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
    
    init(_ postFilter: PostFilter?) {
        _customizePostFilterViewModel = StateObject(
            wrappedValue: CustomizePostFilterViewModel(
                postFilter: postFilter,
                customizePostFilterRepository: CustomizePostFilterRepository()
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
                    
                    CustomTextField("Post Filter Name", text: $customizePostFilterViewModel.name)
                }
                .padding(16)
            }
            .listPlainItemNoInsets()
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
            .listPlainItemNoInsets()
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
            .listPlainItemNoInsets()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            FilledCardView {
                VStack(spacing: 16) {
                    Text("Posts will be filtered out if they contain the following keywords in their title")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Title: excludes keywords (key1,key2)", text: $customizePostFilterViewModel.excludesKeywords)
                    
                    Text("Posts will be filtered out if they do not contain the following keywords in their title.")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Title: contains keywords (key1,key2)", text: $customizePostFilterViewModel.containsKeywords)
                }
                .padding(16)
            }
            .listPlainItemNoInsets()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            FilledCardView {
                VStack(spacing: 16) {
                    Text("Posts will be filtered out if their title matches the following regular expression.")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Title: excludes regex", text: $customizePostFilterViewModel.excludesRegex)
                    
                    Text("Posts will be filtered out if their title does not match the following regular expression.")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Title: contains regex", text: $customizePostFilterViewModel.containsRegex)
                }
                .padding(16)
            }
            .listPlainItemNoInsets()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            FilledCardView {
                VStack(spacing: 16) {
                    Text("Posts from the following subreddits will be filtered out.")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 0) {
                        CustomTextField("E.g. funny,AskReddit", text: $customizePostFilterViewModel.excludeSubreddits)
                        
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
                        CustomTextField("E.g. Hostilenemy,random", text: $customizePostFilterViewModel.excludeUsers)
                        
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
                    Text("Posts that have the following flairs will be filtered out.")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Exclude flairs (e.g., flair1,flair2)", text: $customizePostFilterViewModel.excludeFlairs)
                    
                    Text("Posts that do not have the following flairs will be filtered out.")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Contain flairs (e.g., flair1,flair2)", text: $customizePostFilterViewModel.containFlairs)
                }
                .padding(16)
            }
            .listPlainItemNoInsets()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            FilledCardView {
                VStack(spacing: 16) {
                    Text("Link posts that have the following urls will be filtered out.")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Exclude domains", text: $customizePostFilterViewModel.excludeDomains)
                    
                    Text("Link posts that do not have the following urls will be filtered out.")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Contain domains", text: $customizePostFilterViewModel.containDomains)
                }
                .padding(16)
            }
            .listPlainItemNoInsets()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            FilledCardView {
                VStack(spacing: 16) {
                    Text("Posts that have a score lower than the following value will be filtered out (-1 means no restriction).")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Min vote (-1: no restriction)", text: $customizePostFilterViewModel.minVoteString)
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
                    
                    CustomTextField("Max vote (-1: no restriction)", text: $customizePostFilterViewModel.maxVoteString)
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
            .listPlainItemNoInsets()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            FilledCardView {
                VStack(spacing: 16) {
                    Text("Posts will be filtered out if the number of their comments is less than the following value. (-1 means no restriction).")
                        .primaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField("Min comments (-1: no restriction)", text: $customizePostFilterViewModel.minCommentsString)
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
                    
                    CustomTextField("Max comments (-1: no restriction)", text: $customizePostFilterViewModel.maxCommentsString)
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
            .listPlainItemNoInsets()
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .themedList()
        .themedNavigationBar()
        .toolbar {
            Button("", systemImage: "tray.and.arrow.down.fill") {
                customizePostFilterViewModel.savePostFilter()
                dismiss()
            }
        }
    }
}
