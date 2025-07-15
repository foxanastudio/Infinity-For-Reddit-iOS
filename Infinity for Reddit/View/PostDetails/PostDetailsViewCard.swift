//
//  PostDetailsViewCard.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-31.
//

import SwiftUI
import SDWebImageSwiftUI
import MarkdownUI
import Flow

struct PostDetailsViewCard: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    @StateObject var postViewModel: PostViewModel
    @State var voteTask: Task<Void, Never>?
    @State var saveTask: Task<Void, Never>?
    
    let formatter = DateFormatter()
    let isFromSubredditPostListing: Bool
    
    init(account: Account, post: Post, isFromSubredditPostListing: Bool) {
        formatter.dateFormat = "y-MM-dd H:mm"
        self.isFromSubredditPostListing = isFromSubredditPostListing
        _postViewModel = StateObject(wrappedValue: PostViewModel(account: account, post: post, postRepository: PostRepository()))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 16)
            
            HStack(alignment: .center) {
                CustomWebImage(
                    postViewModel.post.subredditOrUserIconInPostDetails,
                    width: 24,
                    height: 24,
                    circleClipped: true,
                    handleImageTapGesture: false,
                    fallbackView: {
                        SwiftUI.Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                )
                .frame(width: 24, height: 24)
                .onTapGesture {
                    navigationManager.path.append(AppNavigation.subredditDetails(subredditName: postViewModel.post.subreddit))
                }
                
                VStack(alignment: .leading) {
                    Text(postViewModel.post.subredditNamePrefixed)
                        .subreddit()
                    
                    Text("u/\(postViewModel.post.author)")
                        .username()
                        .onTapGesture {
                            navigationManager.path.append(AppNavigation.userDetails(username: postViewModel.post.author))
                        }
                }
                .padding(.leading, 4)
                
                Spacer()
                
                Text(formatter.string(from: Date(timeIntervalSince1970: TimeInterval(postViewModel.post.createdUtc))))
                    .secondaryText()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            Text(postViewModel.post.title)
                .font(.system(size: 24))
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .postTitle()
            
            HFlow(alignment: .center) {
                PostTypeTag(post: postViewModel.post)
                
                if postViewModel.post.spoiler {
                    SpoilerTag()
                }
                
                if postViewModel.post.over18 {
                    SensitiveTag()
                }
                
                FlairView(flairRichtext: postViewModel.post.linkFlairRichtext)
                
                UpvoteRatioTag(post: postViewModel.post)
                
                if postViewModel.post.archived {
                    ArchivedTag()
                }
                
                if postViewModel.post.locked {
                    LockedTag()
                }
                
                if postViewModel.post.crosspostParent != nil {
                    CrosspostTag()
                }
                
                switch postViewModel.post.postType {
                case .link:
                    if let url = URL(string: postViewModel.post.url), let domain = url.host {
                        Text(domain)
                            .secondaryText()
                    }
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
                .frame(height: 8)
            
            switch postViewModel.post.postType {
            case .noPreviewLink:
                if let url = URL(string: postViewModel.post.url), let domain = url.host {
                    Text(domain)
                        .noPreviewPostTypeIndicatorBackground()
                        .noPreviewPostTypeIndicator()
                        .padding(.bottom, 8)
                        .onTapGesture {
                            LinkHandler.shared.handle(url: url)
                        }
                }
            default:
                EmptyView()
            }
            
            if let galleryData = postViewModel.post.galleryData,
                      !galleryData.items.isEmpty,
                      let mediaMetadata = postViewModel.post.mediaMetadata,
                      let preview = mediaMetadata[galleryData.items[0].mediaId] {
                Spacer()
                    .frame(height: 10)
                
                // May not have a preview!!!!!!
                GalleryCarousel(post: postViewModel.post)
                    .aspectRatio(preview.s.aspectRatio, contentMode: .fit)
            } else if postViewModel.post.postType != .text, let preview = postViewModel.post.preview, preview.images.count > 0, let url = preview.images[0].source.url {
                Spacer()
                    .frame(height: 10)
                
                GeometryReader { geo in
                    ZStack(alignment: .topLeading) {
                        CustomWebImage(
                            url,
                            aspectRatio: preview.images[0].source.aspectRatio,
                            matchedGeometryEffectId: UUID().uuidString,
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
            } else if postViewModel.post.postType.isMedia {
                Spacer()
                    .frame(height: 8)
                
                // No preview media
                ZStack {
                    switch postViewModel.post.postType {
                    case .video, .imgurVideo, .redgifs, .streamable:
                        SwiftUI.Image(systemName: "video")
                            .noPreviewPostTypeIndicator()
                    case .gallery:
                        SwiftUI.Image(systemName: "square.stack")
                            .noPreviewPostTypeIndicator()
                    default:
                        // Image and some weird post types
                        SwiftUI.Image(systemName: "photo")
                            .noPreviewPostTypeIndicator()
                    }
                    
                }
                .noPreviewPostTypeIndicatorBackground()
                .mediaTapGesture(post: postViewModel.post, aspectRatio: nil, matchedGeometryEffectId: nil)
            }
            
            if let selftext = postViewModel.post.selftextProcessedMarkdown {
                Markdown(selftext)
                    .markdownImageProvider(WebImageProvider(mediaMetadata: postViewModel.post.mediaMetadata))
                    .font(.system(size: 24))
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .themedPostCommentMarkdown()
                    .markdownLinkHandler { url in
                        LinkHandler.shared.handle(url: url)
                    }
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
        .padding(.vertical, 0)
    }
}
