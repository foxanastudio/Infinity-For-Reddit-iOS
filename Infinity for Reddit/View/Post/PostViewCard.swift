//
//  PostViewCard.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-08.
//

import SwiftUI
import SDWebImageSwiftUI

struct PostViewCard: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    @StateObject var postViewModel: PostViewModel
    @State var voteTask: Task<Void, Never>?
    @State var saveTask: Task<Void, Never>?
    
    let formatter = DateFormatter()
    
    init(account: Account, post: Post) {
        formatter.dateFormat = "y-MM-dd H:mm"
        _postViewModel = StateObject(wrappedValue: PostViewModel(account: account, post: post, postRepository: PostRepository()))
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -1)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
                .padding(.top, 8)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text(postViewModel.post.subredditNamePrefixed)
                            .subreddit()
                            .onTapGesture {
                                navigationManager.path.append(AppNavigation.subredditDetails(subredditName: postViewModel.post.subreddit))
                            }
                        
                        Text("u/\(postViewModel.post.author)")
                            .username()
                            .onTapGesture {
                                navigationManager.path.append(AppNavigation.userDetails(username: postViewModel.post.author))
                            }
                    }
                    
                    Spacer()
                    
                    Text(formatter.string(from: Date(timeIntervalSince1970: TimeInterval(postViewModel.post.createdUtc))))
                        .secondaryText()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                Text(postViewModel.post.title)
                    .font(.system(size: 24))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .postTitle()
                
                switch postViewModel.post.postType {
                case .link, .noPreviewLink:
                    if let url = URL(string: postViewModel.post.url), let domain = url.host {
                        Text(domain)
                            .secondaryText()
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }
                default:
                    EmptyView()
                }
                
                if let galleryData = postViewModel.post.galleryData,
                          !galleryData.items.isEmpty,
                          let mediaMetadata = postViewModel.post.mediaMetadata,
                          let preview = mediaMetadata[galleryData.items[0].mediaId] {
                    // May not have a preview!!!!!!
                    GalleryCarousel(post: postViewModel.post)
                        .aspectRatio(preview.s.aspectRatio, contentMode: .fit)
                } else if case .text = postViewModel.post.postType, let selftextTruncated = postViewModel.post.selftextTruncated {
                    Text(selftextTruncated)
                        .postContent()
                        .padding(.horizontal, 16)
                } else if let preview = postViewModel.post.preview, preview.images.count > 0, let url = preview.images[0].source.url {
                    GeometryReader { geo in
                        ZStack(alignment: .topLeading) {
                            CustomWebImage(
                                url,
                                aspectRatio: preview.images[0].source.aspectRatio,
                                enableMatchedGeometryEffect: true,
                                post: postViewModel.post,
                                placeholderView: {
                                    Spacer()
                                        .frame(width: geo.size.width, height: CGFloat(geo.size.width) / (CGFloat(preview.images[0].source.width) / CGFloat(preview.images[0].source.height)))
                                }
                            )
                            
                            switch postViewModel.post.postType {
                            case .video, .imgurVideo, .redgifs, .streamable:
                                SwiftUI.Image(systemName: "play.circle")
                                    .resizable()
                                    .mediaIndicator()
                                    .padding(12)
                                    .frame(width: 64, height: 64)
                            case .link:
                                SwiftUI.Image(systemName: "link.circle")
                                    .resizable()
                                    .mediaIndicator()
                                    .padding(12)
                                    .frame(width: 64, height: 64)
                            default:
                                EmptyView()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(preview.images[0].source.aspectRatio, contentMode: .fit)
                }
                
                HStack(alignment: .center) {
                    Button(action: {
                        voteTask?.cancel()
                        voteTask = Task {
                            await postViewModel.votePost(vote: 1)
                        }
                    }) {
                        SwiftUI.Image(systemName: postViewModel.post.likes == 1 ? "arrowshape.up.fill" : "arrowshape.up")
                            .postIconTemplateRendering()
                            .postUpvoteIcon(isUpvoted: postViewModel.post.likes == 1)
                    }
                    .buttonStyle(.borderless)
                    
                    Text(String(postViewModel.post.score + postViewModel.post.likes))
                        .frame(width: 72, alignment: .center)
                        .postInfo()
                    
                    Button(action: {
                        voteTask?.cancel()
                        voteTask = Task {
                            await postViewModel.votePost(vote: -1)
                        }
                    }) {
                        SwiftUI.Image(systemName: postViewModel.post.likes == -1 ? "arrowshape.down.fill" : "arrowshape.down")
                            .postIconTemplateRendering()
                            .postDownvoteIcon(isDownvoted: postViewModel.post.likes == -1)
                    }
                    .padding(.trailing, 16)
                    .buttonStyle(.borderless)
                    
                    Button {
                        
                    } label: {
                        SwiftUI.Image(systemName: "text.bubble")
                            .postIconTemplateRendering()
                            .postIcon()
                    }
                    .buttonStyle(.borderless)
                    
                    Text(String(postViewModel.post.numComments))
                        .postInfo()
                    
                    Spacer()
                    
                    Button(action: {
                        saveTask?.cancel()
                        saveTask = Task {
                            await postViewModel.savePost(save: !postViewModel.post.saved)
                        }
                    }) {
                        SwiftUI.Image(systemName: postViewModel.post.saved ? "bookmark.fill" : "bookmark")
                            .postIconTemplateRendering()
                            .postIcon()
                    }
                    .padding(.trailing, 16)
                    .buttonStyle(.borderless)
                    
                    ShareLink(item: postViewModel.post.url) {
                        SwiftUI.Image(systemName: "square.and.arrow.up")
                            .postIconTemplateRendering()
                            .postIcon()
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .padding(.vertical, 8)
        }
        .onTapGesture {
            navigationManager.path.append(AppNavigation.postDetails(post: postViewModel.post))
        }
    }
}
