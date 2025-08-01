//
//  CustomizePostFilterView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-07.
//

import SwiftUI
import Swinject
import GRDB

struct CustomizePostFilterView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var postFilterViewModel: PostFilterViewModel
    
    @State private var id: Int? = nil
    @State private var profileName: String = "New Filter"
    @State private var showText = true
    @State private var showLink = true
    @State private var showImage = true
    @State private var showGif = true
    @State private var showVideo = true
    @State private var showGallery = true
    @State private var onlySensitive = false
    @State private var onlySpoiler = false
    @State private var excludesKeywords: String = ""
    @State private var containsKeywords: String = ""
    @State private var excludesRegex: String = ""
    @State private var containsRegex: String = ""
    @State private var excludeSubreddits: String = ""
    @State private var excludeUsers: String = ""
    @State private var excludeFlairs: String = ""
    @State private var containFlairs: String = ""
    @State private var excludeDomains: String = ""
    @State private var containDomains: String = ""
    @State private var minVote: Int = -1
    @State private var maxVote: Int = -1
    @State private var minComments: Int = -1
    @State private var maxComments: Int = -1
    @Binding var postFilterName: String?
    
    init(_ postFilterName: Binding<String?>) {
        self._postFilterName = postFilterName
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .primaryText()
                }
                
                Spacer()
                
                Button(action: {
                    handleSaveAction()
                    dismiss()
                }) {
                    Text("Save")
                        .primaryText()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            
            List {
                FilledCardView {
                    VStack(spacing: 16) {
                        Text("The name should be unique.")
                            .primaryText()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        CustomTextField("Post Filter Name", text: $profileName)
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
                        
                        TogglePreference(isEnabled: $showText, title: "Text", icon: "text.page")
                        
                        TogglePreference(isEnabled: $showLink, title: "Link", icon: "link")
                        
                        TogglePreference(isEnabled: $showImage, title: "Image", icon: "photo")
                        
                        TogglePreference(isEnabled: $showGif, title: "Gif", icon: "photo")
                        
                        TogglePreference(isEnabled: $showVideo, title: "Video", icon: "video")
                        
                        TogglePreference(isEnabled: $showGallery, title: "Gallery", icon: "square.stack")
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
                        
                        TogglePreference(isEnabled: $onlySensitive, title: "Only Sensitive Content", icon: "figure.child.and.lock")
                        
                        TogglePreference(isEnabled: $onlySpoiler, title: "Only Spoiler", icon: "exclamationmark.triangle.fill")
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
                        
                        CustomTextField("Title: excludes keywords (key1,key2)", text: $excludesKeywords)
                        
                        Text("Posts will be filtered out if they do not contain the following keywords in their title.")
                            .primaryText()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        CustomTextField("Title: contains keywords (key1,key2)", text: $containsKeywords)
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
                        
                        CustomTextField("Title: excludes regex", text: $excludesRegex)
                        
                        Text("Posts will be filtered out if their title does not match the following regular expression.")
                            .primaryText()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        CustomTextField("Title: contains regex", text: $containsRegex)
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
                            CustomTextField("E.g. funny,AskReddit", text: $excludeSubreddits)
                            
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
                            CustomTextField("E.g. Hostilenemy,random", text: $excludeUsers)
                            
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
                        
                        CustomTextField("Exclude flairs (e.g., flair1,flair2)", text: $excludeFlairs)
                        
                        Text("Posts that do not have the following flairs will be filtered out.")
                            .primaryText()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        CustomTextField("Contain flairs (e.g., flair1,flair2)", text: $containFlairs)
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
                        
                        CustomTextField("Exclude domains", text: $excludeDomains)
                        
                        Text("Link posts that do not have the following urls will be filtered out.")
                            .primaryText()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        CustomTextField("Contain domains", text: $containDomains)
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
                        
                        CustomTextField("Min vote (-1: no restriction)", text: Binding(
                            get: { String(minVote) },
                            set: { minVote = Int($0) ?? -1 }
                        ))
                        .keyboardType(.numberPad)
                        
                        Text("Posts that have a score higher than the following value will be filtered out (-1 means no restriction).")
                            .primaryText()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        CustomTextField("Max vote (-1: no restriction)", text: Binding(
                            get: { String(maxVote) },
                            set: { maxVote = Int($0) ?? -1 }
                        ))
                        .keyboardType(.numberPad)
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
                        
                        CustomTextField("Min comments (-1: no restriction)", text: Binding(
                            get: { String(minComments) },
                            set: { minComments = Int($0) ?? -1 }
                        ))
                        .keyboardType(.numberPad)
                        
                        Text("Posts will be filtered out if the number of their comments is larger than the following value. (-1 means no restriction).")
                            .primaryText()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        CustomTextField("Max comments (-1: no restriction)", text: Binding(
                            get: { String(maxComments) },
                            set: { maxComments = Int($0) ?? -1 }
                        ))
                        .keyboardType(.numberPad)
                    }
                    .padding(16)
                }
                .listPlainItemNoInsets()
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .themedList()
        }
        .onAppear {
            if let postFilterName = postFilterName {
                if let fetchedPostFilter: PostFilter = try? postFilterViewModel.fetchPostFilter(postFilterName){
                    id = fetchedPostFilter.id
                    profileName = fetchedPostFilter.name
                    showText = fetchedPostFilter.containTextType
                    showLink = fetchedPostFilter.containLinkType
                    showImage = fetchedPostFilter.containImageType
                    showGif = fetchedPostFilter.containGifType
                    showVideo = fetchedPostFilter.containVideoType
                    showGallery = fetchedPostFilter.containGalleryType
                    onlySensitive = fetchedPostFilter.onlyNSFW
                    onlySpoiler = fetchedPostFilter.onlySpoiler
                    excludesKeywords = fetchedPostFilter.postTitleExcludesStrings ?? ""
                    containsKeywords = fetchedPostFilter.postTitleContainsStrings ?? ""
                    excludesRegex = fetchedPostFilter.postTitleExcludesRegex ?? ""
                    containsRegex = fetchedPostFilter.postTitleContainsRegex ?? ""
                    excludeSubreddits = fetchedPostFilter.excludeSubreddits ?? ""
                    excludeUsers = fetchedPostFilter.excludeUsers ?? ""
                    excludeFlairs = fetchedPostFilter.excludeFlairs ?? ""
                    containFlairs = fetchedPostFilter.containFlairs ?? ""
                    excludeDomains = fetchedPostFilter.excludeDomains ?? ""
                    containDomains = fetchedPostFilter.containDomains ?? ""
                    minVote = fetchedPostFilter.minVote
                    maxVote = fetchedPostFilter.maxVote
                    minComments = fetchedPostFilter.minComments
                    maxComments = fetchedPostFilter.maxComments
                } else {
                    print("Failed to fetch post filter with name: \(postFilterName)")
                }
            }
        }
    }
    
    private func handleSaveAction() {
        postFilterViewModel.savePostFilter(
            id: id,
            originalProfileName: postFilterName,
            profileName: profileName,
            maxVote: maxVote,
            minVote: minVote,
            maxComments: maxComments,
            minComments: minComments,
            onlyNSFW: onlySensitive,
            onlySpoiler: onlySpoiler,
            onlySensitive: onlySensitive,
            excludesKeywords: excludesKeywords,
            containsKeywords: containsKeywords,
            excludesRegex: excludesRegex,
            containsRegex: containsRegex,
            excludeSubreddits: excludeSubreddits,
            excludeUsers: excludeUsers,
            excludeFlairs: excludeFlairs,
            containFlairs: containFlairs,
            excludeDomains: excludeDomains,
            containDomains: containDomains,
            showText: showText,
            showLink: showLink,
            showImage: showImage,
            showGif: showGif,
            showVideo: showVideo,
            showGallery: showGallery
        )
    }
}
