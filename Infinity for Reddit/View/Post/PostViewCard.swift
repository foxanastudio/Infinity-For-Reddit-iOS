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
    @AppStorage(InterfacePostUserDefaultsUtils.hidePostTypeKey, store: .interfacePost) private var hidePostType: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hidePostFlairKey, store: .interfacePost) private var hidePostFlair: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideSubredditAndUserPrefixKey, store: .interfacePost) private var hideSubredditAndUserPrefix: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideNVotesKey, store: .interfacePost) private var hideNVotes: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideNCommentsKey, store: .interfacePost) private var hideNComments: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideTextPostContentKey, store: .interfacePost) private var hideTextPostContent: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.limitMediaHeightKey, store: .interfacePost) private var limitMediaHeight: Bool = false
    @AppStorage(InterfaceUserDefaultsUtils.voteButtonsOnTheRightKey, store: .interface) private var voteButtonsOnTheRight: Bool = false
    
    @State var width: CGFloat?
    
    let isSubredditPostListing: Bool
    let onPostTypeClicked: () -> Void
    let onSensitiveClicked: () -> Void
    
    private let iconSize: CGFloat = 24
    
    init(account: Account, post: Post, isSubredditPostListing: Bool, width: CGFloat? = nil, onPostTypeClicked: @escaping () -> Void, onSensitiveClicked: @escaping () -> Void) {
        self.width = width
        self.isSubredditPostListing = isSubredditPostListing
        self.onPostTypeClicked = onPostTypeClicked
        self.onSensitiveClicked = onSensitiveClicked
        _postViewModel = StateObject(wrappedValue: PostViewModel(account: account, post: post, postRepository: PostRepository()))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 16)
            
            HStack {
                CustomWebImage(
                    postViewModel.post.subredditOrUserIcon,
                    width: iconSize,
                    height: iconSize,
                    circleClipped: true,
                    handleImageTapGesture: false,
                    fallbackView: {
                        InitialLetterAvatarImageFallbackView(name: isSubredditPostListing ? postViewModel.post.author : postViewModel.post.subreddit, size: iconSize)
                    }
                )
                .frame(width: iconSize, height: iconSize)
                .onTapGesture {
                    if (!isSubredditPostListing) {
                        navigationManager.path.append(AppNavigation.subredditDetails(subredditName: postViewModel.post.subreddit))
                    } else if !postViewModel.post.isAuthorDeleted() {
                        navigationManager.path.append(AppNavigation.userDetails(username: postViewModel.post.author))
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(hideSubredditAndUserPrefix ? postViewModel.post.subreddit : postViewModel.post.subredditNamePrefixed)
                        .subreddit()
                        .onTapGesture {
                            navigationManager.path.append(AppNavigation.subredditDetails(subredditName: postViewModel.post.subreddit))
                        }
                    
                    Text(hideSubredditAndUserPrefix ? postViewModel.post.author : "u/\(postViewModel.post.author ?? "")")
                        .usernameOnPost(post: postViewModel.post)
                        .onTapGesture {
                            navigationManager.path.append(AppNavigation.userDetails(username: postViewModel.post.author))
                        }
                }
                .padding(.leading, 4)
                
                Spacer()
                
                TimeText(timeUTCInSeconds: postViewModel.post.createdUtc)
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
                if !hidePostType {
                    PostTypeTag(post: postViewModel.post)
                        .onTapGesture {
                            onPostTypeClicked()
                        }
                }
                
                if postViewModel.post.spoiler {
                    SpoilerTag()
                }
                
                if postViewModel.post.over18 {
                    SensitiveTag()
                        .onTapGesture {
                            onSensitiveClicked()
                        }
                }
                
                if !hidePostFlair {
                    FlairView(flairRichtext: postViewModel.post.linkFlairRichtext,
                              flairText: postViewModel.post.linkFlairText)
                }
                
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
                            navigationManager.openLink(url)
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
                .applyIf(limitMediaHeight) {
                    $0.frame(height: 200)
                }
                .applyIf(!limitMediaHeight) {
                    $0.aspectRatio(preview.s.aspectRatio, contentMode: .fit)
                }
            } else if !hideTextPostContent, case .text = postViewModel.post.postType, let selftextTruncated = postViewModel.post.selftextTruncated, !selftextTruncated.isEmpty {
                Spacer()
                    .frame(height: 6)
                
                Text(selftextTruncated)
                    .postContent()
                    .padding(.horizontal, 16)
            } else if case .redditVideo(let videoUrlString, _) = postViewModel.post.postType {
                Spacer()
                    .frame(height: 10)
                
                PostVideoView(post: postViewModel.post, videoUrl: videoUrlString, inPostListing: true) {
                    Task {
                        await postViewModel.readPost()
                    }
                }
            } else if case .video(let videoUrlString, _) = postViewModel.post.postType {
                Spacer()
                    .frame(height: 10)
                
                PostVideoView(post: postViewModel.post, videoUrl: videoUrlString, inPostListing: true) {
                    Task {
                        await postViewModel.readPost()
                    }
                }
            } else if let preview = postViewModel.post.preview, preview.images.count > 0, let url = preview.images[0].source.url {
                Spacer()
                    .frame(height: 10)
                
                ZStack(alignment: .topLeading) {
                    CustomWebImage(
                        url,
                        height: limitMediaHeight ? 200 : nil,
                        aspectRatio: limitMediaHeight ? nil : preview.images[0].source.aspectRatio,
                        centerCrop: limitMediaHeight,
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
                    case .redditVideo, .video, .imgurVideo, .redgifs, .streamable:
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
                .frame(maxWidth: .infinity)
            } else if postViewModel.post.postType.isMedia {
                Spacer()
                    .frame(height: 8)
                
                // No preview media
                ZStack {
                    switch postViewModel.post.postType {
                    case .redditVideo, .video, .imgurVideo, .redgifs, .streamable:
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
            
            HStack(spacing: 0) {
                HStack(spacing: 0) {
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
                    .padding(8)
                    .contentShape(Rectangle())
                    
                    VotesText(votes: postViewModel.post.score + postViewModel.post.likes, hideNVotes: hideNVotes)
                        .frame(width: 72, alignment: .center)
                        .postInfo()
                        .contentShape(Rectangle())
                        .onTapGesture {}
                    
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
                    .buttonStyle(.borderless)
                    .padding(8)
                    .contentShape(Rectangle())
                }
                .environment(\.layoutDirection, .leftToRight)

                HStack {
                    if !hideNComments {
                        Button {
                            
                        } label: {
                            SwiftUI.Image(systemName: "text.bubble")
                                .postIconTemplateRendering()
                                .postIcon()
                        }
                        .buttonStyle(.borderless)
                        
                        Text(String(postViewModel.post.numComments))
                            .postInfo()
                    }
                    
                    Spacer()
                }
                .padding(.leading, 16)
                .environment(\.layoutDirection, .leftToRight)
                
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
                .buttonStyle(.borderless)
                .padding(8)
                .contentShape(Rectangle())
                
                ShareLink(item: postViewModel.post.url) {
                    SwiftUI.Image(systemName: "square.and.arrow.up")
                        .postIconTemplateRendering()
                        .postIcon()
                }
                .buttonStyle(.borderless)
                .padding(8)
                .contentShape(Rectangle())
            }
            .environment(\.layoutDirection, voteButtonsOnTheRight ? .rightToLeft : .leftToRight)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
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
