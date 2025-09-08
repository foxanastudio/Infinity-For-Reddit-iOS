//
//  PostViewCard.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-08.
//

import SwiftUI
import SDWebImageSwiftUI
import Flow

struct PostViewCard: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    @StateObject var postViewModel: PostViewModel
    @State var voteTask: Task<Void, Never>?
    @State var saveTask: Task<Void, Never>?
    
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSensitiveImagesKey, store: .contentSensitivityFilter) private var blurSensitiveImages: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSpoilerImagesKey, store: .contentSensitivityFilter) private var blurSpoilerImages: Bool = false
    
    let isSubredditPostListing: Bool
    
    let formatter = DateFormatter()
    @State var width: CGFloat?
    
    init(account: Account, post: Post, isSubredditPostListing: Bool, width: CGFloat? = nil) {
        self.isSubredditPostListing = isSubredditPostListing
        formatter.dateFormat = "y-MM-dd H:mm"
        self.width = width
        _postViewModel = StateObject(wrappedValue: PostViewModel(account: account, post: post, postRepository: PostRepository()))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 16)
            
            HStack(alignment: .center) {
                CustomWebImage(
                    postViewModel.post.subredditOrUserIcon,
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
                    if (!isSubredditPostListing) {
                        navigationManager.path.append(AppNavigation.subredditDetails(subredditName: postViewModel.post.subreddit))
                    } else if !postViewModel.post.isAuthorDeleted() {
                        navigationManager.path.append(AppNavigation.userDetails(username: postViewModel.post.author))
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(postViewModel.post.subredditNamePrefixed)
                        .subreddit()
                        .onTapGesture {
                            navigationManager.path.append(AppNavigation.subredditDetails(subredditName: postViewModel.post.subreddit))
                        }
                    
                    Text("u/\(postViewModel.post.author)")
                        .usernameOnPost(post: postViewModel.post)
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
                
                FlairView(flairRichtext: postViewModel.post.linkFlairRichtext,
                          flairText: postViewModel.post.linkFlairText)
                
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
                    Spacer()
                        .frame(height: 10)
                    
                    Text(domain)
                        .noPreviewPostTypeIndicatorBackground()
                        .noPreviewPostTypeIndicator()
                        .onTapGesture {
                            LinkHandler.shared.handle(url: url)
                            Task {
                                await postViewModel.readPost()
                            }
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
                GalleryCarousel(post: postViewModel.post) {
                    Task {
                        await postViewModel.readPost()
                    }
                }
                .aspectRatio(preview.s.aspectRatio, contentMode: .fit)
            } else if case .text = postViewModel.post.postType, let selftextTruncated = postViewModel.post.selftextTruncated, !selftextTruncated.isEmpty {
                Spacer()
                    .frame(height: 6)
                
                Text(selftextTruncated)
                    .postContent()
                    .padding(.horizontal, 16)
            } else if case .video(let videoUrl, _) = postViewModel.post.postType {
                if let preview = postViewModel.post.preview, preview.images.count > 0 {
                    MarkdownVideoPlayer(videoURL: URL(string: videoUrl)!, aspectRatio: preview.images[0].source.aspectRatio)
                } else {
                    MarkdownVideoPlayer(videoURL: URL(string: videoUrl)!, aspectRatio: nil)
                        .frame(height: 400)
                }
            } else if let preview = postViewModel.post.preview, preview.images.count > 0, let url = preview.images[0].source.url {
                Spacer()
                    .frame(height: 10)
                
                GeometryReader { geo in
                    ZStack(alignment: .topLeading) {
                        CustomWebImage(
                            url,
                            aspectRatio: preview.images[0].source.aspectRatio,
                            matchedGeometryEffectId: UUID().uuidString,
                            post: postViewModel.post,
                            blur: (postViewModel.post.over18 && blurSensitiveImages) || (postViewModel.post.spoiler && blurSpoilerImages)
                        )
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded {
                                    Task {
                                        await postViewModel.readPost()
                                    }
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
            
            HStack(alignment: .center) {
                Button(action: {
                    if !accountViewModel.account.isAnonymous() {
                        voteTask?.cancel()
                        voteTask = Task {
                            await postViewModel.votePost(vote: 1)
                        }
                    }
                }) {
                    SwiftUI.Image(systemName: postViewModel.post.likes == 1 && !accountViewModel.account.isAnonymous() ? "arrowshape.up.fill" : "arrowshape.up")
                        .postIconTemplateRendering()
                        .postUpvoteIcon(isUpvoted: postViewModel.post.likes == 1 && !accountViewModel.account.isAnonymous())
                }
                .buttonStyle(.borderless)
                
                Text(String(postViewModel.post.score + postViewModel.post.likes))
                    .frame(width: 72, alignment: .center)
                    .postInfo()
                
                Button(action: {
                    if !accountViewModel.account.isAnonymous() {
                        voteTask?.cancel()
                        voteTask = Task {
                            await postViewModel.votePost(vote: -1)
                        }
                    }
                }) {
                    SwiftUI.Image(systemName: postViewModel.post.likes == -1 && !accountViewModel.account.isAnonymous() ? "arrowshape.down.fill" : "arrowshape.down")
                        .postIconTemplateRendering()
                        .postDownvoteIcon(isDownvoted: postViewModel.post.likes == -1 && !accountViewModel.account.isAnonymous())
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
        .background {
            TouchRipple(backgroundShape: RoundedRectangle(cornerRadius: 20)) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: postViewModel.post.isRead ? themeViewModel.currentCustomTheme.readPostCardViewBackgroundColor : themeViewModel.currentCustomTheme.cardViewBackgroundColor))
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -1)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
            }
        }
        .padding(.vertical, 8)
        .onTapGesture {
            Task {
                await postViewModel.readPost()
            }
            navigationManager.path.append(AppNavigation.postDetails(postDetailsInput: .post(postViewModel.post), isFromSubredditPostListing: isSubredditPostListing))
        }
    }
}
