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
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @EnvironmentObject var customThemeViewModel: CustomThemeViewModel
    
    //@StateObject var postViewModel: PostViewModel
    @ObservedObject var post: Post
    //@State var voteTask: Task<Void, Never>?
    @State var saveTask: Task<Void, Never>?
    
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSensitiveImagesKey, store: .contentSensitivityFilter) private var blurSensitiveImages: Bool = true
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSpoilerImagesKey, store: .contentSensitivityFilter) private var blurSpoilerImages: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hidePostTypeKey, store: .interfacePostDetails) private var hidePostType: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hidePostFlairKey, store: .interfacePostDetails) private var hidePostFlair: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hideUpvoteRatioKey, store: .interfacePostDetails) private var hideUpvoteRatio: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hideSubredditAndUserPrefixKey, store: .interfacePostDetails) private var hideSubredditAndUserPrefix: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hideNVotesKey, store: .interfacePostDetails) private var hideNVotes: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hideNCommentsKey, store: .interfacePostDetails) private var hideNComments: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.markdownEmbeddedMediaTypeKey, store: .interfacePostDetails) private var markdownEmbeddedMediaType: Int = 15
    @AppStorage(InterfaceUserDefaultsUtils.voteButtonsOnTheRightKey, store: .interface) private var voteButtonsOnTheRight: Bool = false

    let playbackTimeToSeekToInitially: Double
    let onUpvote: () -> Void
    let onDownvote: () -> Void
    let onToggleSave: () async -> Void
    let onSendComment: () -> Void
    let onShare: () -> Void
    let onLongPress: () -> Void
    let onLongPressOnContent: () -> Void
    
    private let iconSize: CGFloat = 24
    
    init(
        post: Post,
        playbackTimeToSeekToInitially: Double,
        onUpvote: @escaping () -> Void,
        onDownvote: @escaping () -> Void,
        onToggleSave: @escaping () async -> Void,
        onSendComment: @escaping () -> Void,
        onShare: @escaping () -> Void,
        onLongPress: @escaping () -> Void,
        onLongPressOnContent: @escaping () -> Void
    ) {
        self.post = post
        self.playbackTimeToSeekToInitially = playbackTimeToSeekToInitially
        self.onUpvote = onUpvote
        self.onDownvote = onDownvote
        self.onToggleSave = onToggleSave
        self.onSendComment = onSendComment
        self.onShare = onShare
        self.onLongPress = onLongPress
        self.onLongPressOnContent = onLongPressOnContent
        //_postViewModel = StateObject(wrappedValue: PostViewModel(post: post, postRepository: PostRepository()))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: 16)
            
            HStack {
                CustomWebImage(
                    post.subredditIconUrlString,
                    width: iconSize,
                    height: iconSize,
                    circleClipped: true,
                    handleImageTapGesture: false,
                    fallbackView: {
                        InitialLetterAvatarImageFallbackView(name: post.subreddit, size: iconSize)
                    }
                )
                .frame(width: iconSize, height: iconSize)
                .onTapGesture {
                    goToSubredditDetails()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(hideSubredditAndUserPrefix ? post.subreddit : post.subredditNamePrefixed)
                        .subreddit()
                        .onTapGesture {
                            goToSubredditDetails()
                        }
                    
                    Text(hideSubredditAndUserPrefix ? post.author : "u/\(post.author ?? "")")
                        .usernameOnPost(post: post)
                        .onTapGesture {
                            goToUserDetails()
                        }
                    
                    AuthorFlairView(flairRichtext: post.authorFlairRichtext, flairText: post.authorFlairText)
                        .padding(.top, 4)
                        .onTapGesture {
                            goToUserDetails()
                        }
                }
                .padding(.leading, 4)
                
                Spacer()
                
                TimeText(timeUTCInSeconds: post.createdUtc)
                    .secondaryText()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .contentShape(Rectangle())
            .onLongPressGesture {
                onLongPress()
            }
            
            Text(post.title)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .postTitle(isRead: false)
                .contentShape(Rectangle())
                .onLongPressGesture {
                    onLongPress()
                }
            
            if hidePostType && !post.spoiler
                && !post.over18 && hidePostFlair
                && hideUpvoteRatio && !post.archived
                && !post.locked && post.crosspostParent == nil
                && post.postType != .link {
                // Not showing post metadata
                EmptyView()
            } else {
                HFlow(alignment: .center) {
                    if !hidePostType {
                        PostTypeTag(post: post)
                            .onTapGesture {
                                navigationManager.append(
                                    AppNavigation.filteredPosts(
                                        postListingMetadata: PostListingMetadata.getSubredditMetadadata(
                                            subredditName: post.subreddit, accountViewModel: accountViewModel
                                        ),
                                        postFilter: PostFilter.constructPostFilter(postType: post.postType)
                                    )
                                )
                            }
                    }
                    
                    if post.spoiler {
                        SpoilerTag()
                    }
                    
                    if post.over18 {
                        SensitiveTag()
                            .onTapGesture {
                                var postFilter = PostFilter()
                                postFilter.onlySensitive = true
                                navigationManager.append(
                                    AppNavigation.filteredPosts(
                                        postListingMetadata: PostListingMetadata.getSubredditMetadadata(
                                            subredditName: post.subreddit, accountViewModel: accountViewModel
                                        ),
                                        postFilter: postFilter
                                    )
                                )
                            }
                    }
                    
                    if !hidePostFlair {
                        FlairView(flairRichtext: post.linkFlairRichtext,
                                  flairText: post.linkFlairText)
                    }
                    
                    if !hideUpvoteRatio {
                        UpvoteRatioTag(post: post)
                    }
                    
                    if post.archived {
                        ArchivedTag()
                    }
                    
                    if post.locked {
                        LockedTag()
                    }
                    
                    if post.crosspostParent != nil {
                        CrosspostTag()
                    }
                    
                    switch post.postType {
                    case .link:
                        if let url = URL(string: post.url), let domain = url.host {
                            Text(domain)
                                .secondaryText()
                        }
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onLongPressGesture {
                    onLongPress()
                }
            }
            
            Group {
                switch post.postType {
                case .noPreviewLink:
                    if let url = URL(string: post.url), let domain = url.host {
                        NoPreviewLinkView(domain: domain) {
                            navigationManager.openLink(url)
                        }
                    } else if let crosspost = post.crosspostParent, let url = URL(string: crosspost.url), let domain = url.host {
                        NoPreviewLinkView(domain: domain) {
                            navigationManager.openLink(url)
                        }
                    }
                default:
                    EmptyView()
                }
            }
            .contentShape(Rectangle())
            .onLongPressGesture {
                onLongPress()
            }
            
            if let galleryData = post.galleryData,
                      !galleryData.items.isEmpty,
                      let mediaMetadata = post.mediaMetadata,
                      let preview = mediaMetadata[galleryData.items[0].mediaId] {
                Spacer()
                    .frame(height: 10)
                
                // May not have a preview!!!!!!
                GalleryCarousel(post: post)
                    .applyIf(preview.s?.aspectRatio != nil) {
                        $0.aspectRatio(preview.s!.aspectRatio, contentMode: .fit)
                    }
                    .contentShape(Rectangle())
                    .onLongPressGesture {
                        onLongPress()
                    }
            } else if case .redditVideo(let videoUrlString, _) = post.postType {
                Spacer()
                    .frame(height: 10)
                
                PostVideoViewSelfContainedViewModel(post: post, videoUrlString: videoUrlString, playbackTimeToSeekToInitially: playbackTimeToSeekToInitially)
            } else if case .video(let videoUrlString, _) = post.postType {
                Spacer()
                    .frame(height: 10)
                
                PostVideoViewSelfContainedViewModel(post: post, videoUrlString: videoUrlString, playbackTimeToSeekToInitially: playbackTimeToSeekToInitially)
            } else if post.postType.isMedia {
                Spacer()
                    .frame(height: 10)
                
                PostPreviewView(post: post)
                    .contentShape(Rectangle())
                    .onLongPressGesture {
                        onLongPress()
                    }
            }
            
            if let selftext = post.selftextProcessedMarkdown {
                Markdown(selftext)
                    .markdownImageProvider(
                        MarkdownImageProvider(
                            mediaMetadata: post.mediaMetadata,
                            markdownEmbeddedMediaType: markdownEmbeddedMediaType,
                            isSensitive: post.over18,
                            linkColor: Color(hex: customThemeViewModel.currentCustomTheme.linkColor),
                            fullScreenMediaViewModel: fullScreenMediaViewModel
                        ) { url in
                            navigationManager.openLink(url)
                        } onFullScreenVideo: { videoUrlString in
                            fullScreenMediaViewModel.show(
                                .video(urlString: videoUrlString, videoType: .direct, canDownload: false)
                            )
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .themedPostContentMarkdown()
                    .markdownLinkHandler { url in
                        navigationManager.openLink(url)
                    }
                    .highPriorityGesture(
                        LongPressGesture()
                            .onEnded { _ in
                                onLongPressOnContent()
                            }
                    )
            }
            
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        onUpvote()
                    }) {
                        SwiftUI.Image(systemName: post.likes == 1 ? "arrowshape.up.fill" : "arrowshape.up")
                            .postIconTemplateRendering()
                            .postUpvoteIcon(isUpvoted: post.likes == 1)
                    }
                    .buttonStyle(.borderless)
                    .padding(8)
                    .contentShape(Rectangle())
                    
                    VotesText(votes: accountViewModel.account.isAnonymous() ? post.score : post.score + post.likes, hideNVotes: hideNVotes)
                        .frame(width: 72, alignment: .center)
                        .postInfo()
                    
                    Button(action: {
                        onDownvote()
                    }) {
                        SwiftUI.Image(systemName: post.likes == -1 ? "arrowshape.down.fill" : "arrowshape.down")
                            .postIconTemplateRendering()
                            .postDownvoteIcon(isDownvoted: post.likes == -1)
                    }
                    .buttonStyle(.borderless)
                    .padding(8)
                    .contentShape(Rectangle())
                }
                .environment(\.layoutDirection, .leftToRight)
                
                HStack {
                    HStack {
                        SwiftUI.Image(systemName: "text.bubble")
                            .postIconTemplateRendering()
                            .postIcon()
                        
                        if !hideNComments {
                            Text(String(post.numComments))
                                .postInfo()
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !accountViewModel.account.isAnonymous() && post.canReply {
                            onSendComment()
                        }
                    }
                    
                    Spacer()
                }
                .padding(.leading, 16)
                .environment(\.layoutDirection, .leftToRight)
                
                Button(action: {
                    saveTask?.cancel()
                    saveTask = Task {
                        await onToggleSave()
                    }
                }) {
                    SwiftUI.Image(systemName: post.saved ? "bookmark.fill" : "bookmark")
                        .postIconTemplateRendering()
                        .postIcon()
                }
                .buttonStyle(.borderless)
                .padding(8)
                .contentShape(Rectangle())
                
//                ShareLink(item: post.url) {
//                    SwiftUI.Image(systemName: "square.and.arrow.up")
//                        .postIconTemplateRendering()
//                        .postIcon()
//                }
//                .buttonStyle(.borderless)
//                .padding(8)
//                .contentShape(Rectangle())
                
                Button(action: onShare) {
                    SwiftUI.Image(systemName: "square.and.arrow.up")
                        .postIconTemplateRendering()
                        .postIcon()
                }
                .buttonStyle(.borderless)
                .padding(8)
                .contentShape(Rectangle())
            }
            .environment(\.layoutDirection, voteButtonsOnTheRight ? .rightToLeft : .leftToRight)
            .padding(8)
            .contentShape(Rectangle())
            .onLongPressGesture {
                onLongPress()
            }
        }
        .padding(.vertical, 0)
        .contentShape(Rectangle())
//        .onLongPressGesture {
//            onLongPress()
//        }
    }
    
    private func goToSubredditDetails() {
        navigationManager.append(AppNavigation.subredditDetails(subredditName: post.subreddit))
    }
    
    private func goToUserDetails() {
        navigationManager.append(AppNavigation.userDetails(username: post.author))
    }
}

private struct NoPreviewLinkView: View {
    let domain: String
    let onTap: () -> Void
    
    var body: some View {
        Spacer()
            .frame(height: 10)
        
        Text(domain)
            .noPreviewPostTypeIndicatorBackground()
            .noPreviewPostTypeIndicator()
            .onTapGesture {
                onTap()
            }
    }
}
