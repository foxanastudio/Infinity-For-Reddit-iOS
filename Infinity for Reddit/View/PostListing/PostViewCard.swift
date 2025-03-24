//
//  PostViewCard.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-08.
//

import SwiftUI
import SDWebImageSwiftUI

struct PostViewCard: View {
    @StateObject var postViewModel: PostViewModel
    
    let formatter = DateFormatter()
    
    init(account: Account, post: Post) {
        formatter.dateFormat = "y-MM-dd H:mm"
        _postViewModel = StateObject(wrappedValue: PostViewModel(account: account, post: post, postRepository: PostRepository()))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(postViewModel.post.subredditNamePrefixed)
                        .subreddit()
                    
                    Text("u/\(postViewModel.post.author)")
                        .username()
                }
                
                Spacer()
                
                Text(formatter.string(from: Date(timeIntervalSince1970: TimeInterval(postViewModel.post.createdUtc))))
                    .secondaryText()
            }
            .padding(.vertical, 8)
            
            Text(postViewModel.post.title)
                .font(.system(size: 24))
                .padding(.bottom, 8)
                .postTitle()
            
            if let preview = postViewModel.post.preview, preview.images.count > 0, let url = preview.images[0].source.url {
                WebImage(url: URL(string: url)) { image in
                    image
                        .resizable()
                        .aspectRatio(preview.images[0].source.aspectRatio, contentMode: .fit)
                }  placeholder: {
                    Rectangle().foregroundColor(.gray)
                }
                .onSuccess { image, data, cacheType in
                    // Success
                    // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                }
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .aspectRatio(preview.images[0].source.aspectRatio, contentMode: .fit)
            } else if let selftextTruncated = postViewModel.post.selftextTruncated {
                Text(selftextTruncated)
            }
            
            HStack(alignment: .center) {
                Button(action: {
                    postViewModel.votePost(vote: 1)
                    postViewModel.post.likes = 1
                }) {
                    SwiftUI.Image(postViewModel.post.likes == 1 ? "upvoted" : "upvote")
                        .postIconTemplateRendering()
                        .postUpvoteIcon(isUpvoted: postViewModel.post.likes == 1)
                }
                .buttonStyle(.borderless)
                
                Text(String(postViewModel.post.score + postViewModel.post.likes))
                    .frame(width: 72, alignment: .center)
                    .postInfo()
                
                Button(action: {
                    postViewModel.votePost(vote: -1)
                }) {
                    SwiftUI.Image(postViewModel.post.likes == -1 ? "downvoted" : "downvote")
                        .postIconTemplateRendering()
                        .postDownvoteIcon(isDownvoted: postViewModel.post.likes == -1)
                }
                .padding(.trailing, 16)
                .buttonStyle(.borderless)
                
                Button {
                    
                } label: {
                    SwiftUI.Image("comment")
                        .postIconTemplateRendering()
                        .postIcon()
                }
                .buttonStyle(.borderless)
                
                Text(String(postViewModel.post.numComments))
                    .postInfo()
                
                Spacer()
                
                Button {
                    
                } label: {
                    SwiftUI.Image(systemName: "square.and.arrow.up")
                        .postIconTemplateRendering()
                        .postIcon()
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 8)
        }
    }
}
