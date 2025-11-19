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
    @EnvironmentObject private var themeViewModel: CustomThemeViewModel

    @AppStorage(InterfacePostUserDefaultsUtils.hidePostTypeKey, store: .interfacePost) private var hidePostType: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hidePostFlairKey, store: .interfacePost) private var hidePostFlair: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideSubredditAndUserPrefixKey, store: .interfacePost) private var hideSubredditAndUserPrefix: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideNVotesKey, store: .interfacePost) private var hideNVotes: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideNCommentsKey, store: .interfacePost) private var hideNComments: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideTextPostContentKey, store: .interfacePost) private var hideTextPostContent: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.limitMediaHeightKey, store: .interfacePost) private var limitMediaHeight: Bool = false
    @AppStorage(InterfaceUserDefaultsUtils.voteButtonsOnTheRightKey, store: .interface) private var voteButtonsOnTheRight: Bool = false

    @ObservedObject var postViewModel: PostViewModel
    @State private var voteTask: Task<Void, Never>?
    @State private var saveTask: Task<Void, Never>?

    let isSubredditPostListing: Bool
    let onPostTap: () -> Void
    let onIconTap: () -> Void
    let onSubredditTap: () -> Void
    let onUserTap: () -> Void
    let onVote: (Int) -> Void
    let onCommentsTap: () -> Void
    let onSave: () -> Void
    let onPostTypeClicked: () -> Void
    let onSensitiveClicked: () -> Void
    let onOpenLink: (URL) -> Void

    private let iconSize: CGFloat = 24

    init(
        postViewModel: PostViewModel,
        isSubredditPostListing: Bool,
        onPostTap: @escaping () -> Void,
        onIconTap: @escaping () -> Void,
        onSubredditTap: @escaping () -> Void,
        onUserTap: @escaping () -> Void,
        onVote: @escaping (Int) -> Void,
        onCommentsTap: @escaping () -> Void,
        onSave: @escaping () -> Void,
        onPostTypeClicked: @escaping () -> Void,
        onSensitiveClicked: @escaping () -> Void,
        onOpenLink: @escaping (URL) -> Void
    ) {
        self.postViewModel = postViewModel
        self.isSubredditPostListing = isSubredditPostListing
        self.onPostTap = onPostTap
        self.onIconTap = onIconTap
        self.onSubredditTap = onSubredditTap
        self.onUserTap = onUserTap
        self.onVote = onVote
        self.onCommentsTap = onCommentsTap
        self.onSave = onSave
        self.onPostTypeClicked = onPostTypeClicked
        self.onSensitiveClicked = onSensitiveClicked
        self.onOpenLink = onOpenLink
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                    onIconTap()
                }
                
                VStack(alignment: .leading) {
                    Text(hideSubredditAndUserPrefix ? postViewModel.post.subreddit : postViewModel.post.subredditNamePrefixed)
                        .subreddit()
                        .onTapGesture {
                            onSubredditTap()
                        }
                    
                    Text(hideSubredditAndUserPrefix ? postViewModel.post.author : "u/\(postViewModel.post.author ?? "")")
                        .usernameOnPost(post: postViewModel.post)
                        .onTapGesture {
                            onUserTap()
                        }
                }
                .padding(.leading, 4)
                
                Spacer()
                
                TimeText(timeUTCInSeconds: postViewModel.post.createdUtc)
                    .secondaryText()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            Text(postViewModel.post.title)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .postTitle()
            
            if hidePostType && !postViewModel.post.spoiler
                && !postViewModel.post.over18 && hidePostFlair
                && !postViewModel.post.archived && !postViewModel.post.locked
                && postViewModel.post.crosspostParent == nil && postViewModel.post.postType != .link {
                // Not showing post metadata
                EmptyView()
            } else {
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
                .padding(.vertical, 8)
            }
            
            switch postViewModel.post.postType {
            case .noPreviewLink:
                if let url = URL(string: postViewModel.post.url), let domain = url.host {
                    NoPreviewLinkView(domain: domain) {
                        onOpenLink(url)
                        Task {
                            await postViewModel.readPost()
                        }
                    }
                } else if let crosspost = postViewModel.post.crosspostParent, let url = URL(string: crosspost.url), let domain = url.host {
                    NoPreviewLinkView(domain: domain) {
                        onOpenLink(url)
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
                
                PostVideoView(post: postViewModel.post, videoUrlString: videoUrlString, inPostListing: true) {
                    Task {
                        await postViewModel.readPost()
                    }
                }
            } else if case .video(let videoUrlString, _) = postViewModel.post.postType {
                Spacer()
                    .frame(height: 10)
                
                PostVideoView(post: postViewModel.post, videoUrlString: videoUrlString, inPostListing: true) {
                    Task {
                        await postViewModel.readPost()
                    }
                }
            } else if postViewModel.post.postType.isMedia {
                Spacer()
                    .frame(height: 10)
                
                PostPreviewView(post: postViewModel.post, inPostListing: true) {
                    Task {
                        await postViewModel.readPost()
                    }
                }
            }
            
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        onVote(1)
                    }) {
                        SwiftUI.Image(systemName: postViewModel.post.likes == 1 ? "arrowshape.up.fill" : "arrowshape.up")
                            .postIconTemplateRendering()
                            .postUpvoteIcon(isUpvoted: postViewModel.post.likes == 1)
                    }
                    .buttonStyle(.borderless)
                    .padding(8)
                    .contentShape(Rectangle())
                    
                    VotesText(votes: accountViewModel.account.isAnonymous() ? postViewModel.post.score : postViewModel.post.score + postViewModel.post.likes, hideNVotes: hideNVotes)
                        .frame(width: 72, alignment: .center)
                        .postInfo()
                        .contentShape(Rectangle())
                        .onTapGesture {}
                    
                    Button(action: {
                        onVote(-1)
                    }) {
                        SwiftUI.Image(systemName: postViewModel.post.likes == -1 ? "arrowshape.down.fill" : "arrowshape.down")
                            .postIconTemplateRendering()
                            .postDownvoteIcon(isDownvoted: postViewModel.post.likes == -1)
                    }
                    .buttonStyle(.borderless)
                    .padding(8)
                    .contentShape(Rectangle())
                }
                .environment(\.layoutDirection, .leftToRight)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture {}

                HStack {
                    if !hideNComments {
                        Button(action: {
                            onCommentsTap()
                        }) {
                            HStack() {
                                SwiftUI.Image(systemName: "text.bubble")
                                    .postIconTemplateRendering()
                                    .postIcon()
                                
                                Text(String(postViewModel.post.numComments))
                                    .postInfo()
                            }
                        }
                        .buttonStyle(.borderless)
                        .contentShape(Rectangle())
                    }
                    
                    Spacer()
                }
                .padding(.leading, voteButtonsOnTheRight ? 8 : 16)
                .environment(\.layoutDirection, .leftToRight)
                
                Button(action: onSave) {
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
            onPostTap()
        }
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
