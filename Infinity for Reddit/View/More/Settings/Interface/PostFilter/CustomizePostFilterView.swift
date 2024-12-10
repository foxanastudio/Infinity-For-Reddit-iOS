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
        NavigationStack {
            Form {
                Section(header: Text("The post filter name should be unique.")) {
                    TextField("Post Filter Name", text: $profileName)
                }
                
                Section(header: Text("To see certain types of posts, please turn on the switch corresponding to the types.")) {
                    Toggle("Text", isOn: $showText)
                    Toggle("Link", isOn: $showLink)
                    Toggle("Image", isOn: $showImage)
                    Toggle("Gif", isOn: $showGif)
                    Toggle("Video", isOn: $showVideo)
                    Toggle("Gallery", isOn: $showGallery)
                }
                
                Section(header: Text("To only see sensitive or spoiler posts, please turn on the corresponding switch.")) {
                    Toggle("Only Sensitive Content", isOn: $onlySensitive)
                    Toggle("Only Spoiler", isOn: $onlySpoiler)
                }
                
                Section(header: Text("Posts will be filtered out if they contain the following")) {
                    Text("This is where you will add UI for filtering out content.")
                }
                Section(header: Text("Posts will be filtered out if they contain the following keywords in their title.")) {
                    TextField("Title: excludes keywords (key1,key2)", text: $excludesKeywords)
                }
                
                Section(header: Text("Posts will be filtered out if they do not contain the following keywords in their title.")) {
                    TextField("Title: contains keywords (key1,key2)", text: $containsKeywords)
                }
                
                Section(header: Text("Posts will be filtered out if their title matches the following regular expression.")) {
                    TextField("Title: excludes regex", text: $excludesRegex)
                }
                
                Section(header: Text("Posts will be filtered out if their title does not match the following regular expression.")) {
                    TextField("Title: contains regex", text: $containsRegex)
                }
                
                Section(header: Text("Posts from the following subreddits will be filtered out.")) {
                    HStack {
                        TextField("Exclude subreddits (e.g., funny,AskReddit)", text: $excludeSubreddits)
                        Button("",  systemImage: "plus"){
                            PostFilterView()
                        }
                    }
                }
                
                Section(header: Text("Posts submitted by the following users will be filtered out.")) {
                    HStack {
                        TextField("Exclude users (e.g., Hostilenemy,random)", text: $excludeUsers)
                        Button("",  systemImage: "plus"){
                            PostFilterView()
                        }
                    }
                }
                Section(header: Text("Posts that have the following flairs will be filtered out.")) {
                    TextField("Exclude flairs (e.g., flair1,flair2)", text: $excludeFlairs)
                }
                
                Section(header: Text("Posts that do not have the following flairs will be filtered out.")) {
                    TextField("Contain flairs (e.g., flair1,flair2)", text: $containFlairs)
                }
                
                Section(header: Text("Link posts that have the following urls will be filtered out.")) {
                    TextField("Exclude domains", text: $excludeDomains)
                }
                
                Section(header: Text("Link posts that do not have the following urls will be filtered out.")) {
                    TextField("Contain domains", text: $containDomains)
                }
                
                Section(header: Text("Posts that have a score lower than the following value will be filtered out (-1 means no restriction).")) {
                    TextField("Min vote (-1: no restriction)", text: Binding(
                        get: { String(minVote) },
                        set: { minVote = Int($0) ?? -1 }
                    ))
                    .keyboardType(.numberPad)
                }
                
                Section(header: Text("Posts that have a score higher than the following value will be filtered out (-1 means no restriction).")) {
                    TextField("Max vote (-1: no restriction)", text: Binding(
                        get: { String(maxVote) },
                        set: { maxVote = Int($0) ?? -1 }
                    ))
                    .keyboardType(.numberPad)
                }
                Section(header: Text("Posts will be filtered out if the number of their comments is less than the following value. (-1 means no restriction).")) {
                    TextField("Min comments (-1: no restriction)", text: Binding(
                        get: { String(minComments) },
                        set: { minComments = Int($0) ?? -1 }
                    ))
                    .keyboardType(.numberPad)
                }
                
                Section(header: Text("Posts will be filtered out if the number of their comments is larger than the following value. (-1 means no restriction).")) {
                    TextField("Max comments (-1: no restriction)", text: Binding(
                        get: { String(maxComments) },
                        set: { maxComments = Int($0) ?? -1 }
                    ))
                    .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Customize Post Filter")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        handleSaveAction()
                        dismiss()
                        
                    }
                }
            }
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
