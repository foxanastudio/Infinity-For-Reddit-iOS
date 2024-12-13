//
//  PostInterfaceView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-11.
//

import Swinject
import GRDB
import SwiftUI

struct PostInterfaceView: View {
    @StateObject var postInterfaceViewModel = PostInterfaceViewModel()
    
    var body: some View {
        List {
            Picker("Default Post Layout", selection: $postInterfaceViewModel.defaultPostLayout) {
                ForEach(0..<postInterfaceViewModel.postLayouts.count, id: \.self) { index in
                    Text(postInterfaceViewModel.postLayouts[index]).tag(index)
                }
            }
            .padding(.leading, 44.5)
            
            Picker("Default Link Post Layout", selection: $postInterfaceViewModel.defaultLinkPostLayout) {
                ForEach(0..<postInterfaceViewModel.linkPostLayouts.count, id: \.self) { index in
                    Text(postInterfaceViewModel.linkPostLayouts[index]).tag(index)
                }
            }
            .padding(.leading, 44.5)
            
            NavigationLink(destination: PostInterfaceView()) {
                Text("The Number of Columns in Post Feed")
            }.padding(.leading, 44.5)
            Toggle("Hide Post Type", isOn: $postInterfaceViewModel.hidePostType).padding(.leading, 44.5)
            Toggle("Hide Post Flair", isOn: $postInterfaceViewModel.hidePostFlair).padding(.leading, 44.5)
            Toggle("Hide Subreddit and User Prefix", isOn: $postInterfaceViewModel.hideSubredditAndUserPrefix).padding(.leading, 44.5)
            Toggle("Hide the Number of Votes", isOn: $postInterfaceViewModel.hideNumberOfVotes).padding(.leading, 44.5)
            Toggle("Hide the Number of Comments", isOn: $postInterfaceViewModel.hideNumberOfComments).padding(.leading, 44.5)
            Toggle("Hide Text Post Content", isOn: $postInterfaceViewModel.hideTextPostContent).padding(.leading, 44.5)
            Toggle("Fixed Height in Card", isOn: $postInterfaceViewModel.fixedHeightInCard).padding(.leading, 44.5)
            Section(header: Text("Compact Layout")) {
                Toggle("Show Divider", isOn: $postInterfaceViewModel.showDivider).padding(.leading, 44.5)
                Toggle("Show Thumbnail on the Left", isOn: $postInterfaceViewModel.showThumbnailOnTheLeft).padding(.leading, 44.5)
                Toggle("Long Press to Hide Toolbar", isOn: $postInterfaceViewModel.longPressToHideToolbar).padding(.leading, 44.5)
                Toggle("Hide Toolbar by Default", isOn: $postInterfaceViewModel.hideToolbarByDefault).padding(.leading, 44.5)
            }
            Section(header: Text("Gallery Layout")) {
                Toggle("Click to Show Media in Gallery Layout", isOn: $postInterfaceViewModel.clickToShowMediaInGalleryLayout).padding(.leading, 44.5)
            }
            .navigationTitle("Post")
        }
        
    }
}


