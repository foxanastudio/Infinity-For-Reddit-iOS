//
//  PostDetailsInterfaceView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-11.
//

import Swinject
import GRDB
import SwiftUI

struct PostDetailsInterfaceView: View {
    @StateObject var postDetailsInterfaceViewModel = PostDetailsInterfaceViewModel()
    
    var body: some View {
        List {
            Toggle(isOn: $postDetailsInterfaceViewModel.separatePostAndCommentsInLandscapeMode){
                VStack(alignment: .leading) {
                    Text("Separate Post And Comments in Landscape Mode")
                    Text("Video autoplay will be disabled in the post detail page")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 44.5)
            
            Toggle("Hide Post Type", isOn: $postDetailsInterfaceViewModel.hidePostType)
                .padding(.leading, 44.5)
                
            Toggle("Hide Post Flair", isOn: $postDetailsInterfaceViewModel.hidePostFlair)
                .padding(.leading, 44.5)
                
            Toggle("Hide Upvote Ratio", isOn: $postDetailsInterfaceViewModel.hideUpvoteRatio)
                .padding(.leading, 44.5)
                
            Toggle("Hide Subreddit and User Prefix", isOn: $postDetailsInterfaceViewModel.hideSubredditAndUserPrefix)
                .padding(.leading, 44.5)
                
            Toggle("Hide the Number of Votes", isOn: $postDetailsInterfaceViewModel.hideNumberOfVotes)
                .padding(.leading, 44.5)
                
            Toggle("Hide the Number of Comments", isOn: $postDetailsInterfaceViewModel.hideNumberOfComments)
                .padding(.leading, 44.5)
                
            Picker("Embedded Media Type", selection: $postDetailsInterfaceViewModel.embeddedMediaType) {
                ForEach(0..<postDetailsInterfaceViewModel.embeddedMediaTypes.count, id: \.self) { index in
                    Text(postDetailsInterfaceViewModel.embeddedMediaTypes[index]).tag(index)
                }
            }
            .padding(.leading, 44.5)
        }
        .navigationTitle("Post Details")
    }
}
