//
//  PostViewCompact.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-10-30.
//

import SwiftUI
import Flow

struct PostViewCompact: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var themeViewModel: CustomThemeViewModel

    @AppStorage(InterfacePostUserDefaultsUtils.hidePostTypeKey, store: .interfacePost) private var hidePostType: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hidePostFlairKey, store: .interfacePost) private var hidePostFlair: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideSubredditAndUserPrefixKey, store: .interfacePost) private var hideSubredditAndUserPrefix: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideNVotesKey, store: .interfacePost) private var hideNVotes: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideNCommentsKey, store: .interfacePost) private var hideNComments: Bool = false
    @AppStorage(InterfaceUserDefaultsUtils.voteButtonsOnTheRightKey, store: .interface) private var voteButtonsOnTheRight: Bool = false
    
    @ObservedObject var postViewModel: PostViewModel
    @State private var voteTask: Task<Void, Never>?
    @State private var saveTask: Task<Void, Never>?

    let isSubredditPostListing: Bool
    let onPostTap: () -> Void
    let onIconTap: () -> Void
    let onSubredditTap: () -> Void
    let onUserTap: () -> Void
    let onUpvote: () async -> Void
    let onDownvote: () async -> Void
    let onCommentsTap: () -> Void
    let onToggleSave: () async -> Void
    let onPostTypeClicked: () -> Void
    let onSensitiveClicked: () -> Void
    let onOpenLink: (URL) -> Void
    let onShare: () -> Void
    let onReadPost: () async -> Void
    let onLongPressPost: () -> Void

    private let iconSize: CGFloat = 24

    init(
        postViewModel: PostViewModel,
        isSubredditPostListing: Bool,
        onPostTap: @escaping () -> Void,
        onIconTap: @escaping () -> Void,
        onSubredditTap: @escaping () -> Void,
        onUserTap: @escaping () -> Void,
        onUpvote: @escaping () async -> Void,
        onDownvote: @escaping () async -> Void,
        onCommentsTap: @escaping () -> Void,
        onToggleSave: @escaping () async -> Void,
        onPostTypeClicked: @escaping () -> Void,
        onSensitiveClicked: @escaping () -> Void,
        onOpenLink: @escaping (_ url: URL) -> Void,
        onShare: @escaping () -> Void,
        onReadPost: @escaping () async -> Void,
        onLongPressPost: @escaping () -> Void
    ) {
        self.postViewModel = postViewModel
        self.isSubredditPostListing = isSubredditPostListing
        self.onPostTap = onPostTap
        self.onIconTap = onIconTap
        self.onSubredditTap = onSubredditTap
        self.onUserTap = onUserTap
        self.onUpvote = onUpvote
        self.onDownvote = onDownvote
        self.onCommentsTap = onCommentsTap
        self.onToggleSave = onToggleSave
        self.onPostTypeClicked = onPostTypeClicked
        self.onSensitiveClicked = onSensitiveClicked
        self.onOpenLink = onOpenLink
        self.onShare = onShare
        self.onReadPost = onReadPost
        self.onLongPressPost = onLongPressPost
    }
    
    var body: some View {
        TouchRipple(
            action: {
                onPostTap()
            },
            onLongPress: {
                onLongPressPost()
            }
        ) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height: 8)
                
                HStack(spacing: 8) {
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

                    Text(hideSubredditAndUserPrefix ? postViewModel.post.subreddit : postViewModel.post.subredditNamePrefixed)
                        .subreddit()
                        .onTapGesture {
                            onSubredditTap()
                        }
                        .padding(.leading, 4)
                    
                    Spacer()
                    
                    TimeText(timeUTCInSeconds: postViewModel.post.createdUtc)
                        .secondaryText()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                HStack (alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(postViewModel.post.title)
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
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    switch postViewModel.post.postType {
                    case .noPreviewLink:
                        if let url = URL(string: postViewModel.post.url), let domain = url.host {
                            NoPreviewLinkView {
                                onOpenLink(url)
                                Task {
                                    await onReadPost()
                                }
                            }
                        } else if let crosspost = postViewModel.post.crosspostParent, let url = URL(string: crosspost.url), let domain = url.host {
                            NoPreviewLinkView {
                                onOpenLink(url)
                                Task {
                                    await onReadPost()
                                }
                            }
                        }
                    default:
                        if postViewModel.post.postType.isMedia {
                            PostPreviewView(post: postViewModel.post, inPostListing: true, isInCompactLayout: true) {
                                Task {
                                    await onReadPost()
                                }
                            }
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Button(action: {
                            voteTask?.cancel()
                            voteTask = Task {
                                await onUpvote()
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
                            voteTask?.cancel()
                            voteTask = Task {
                                await onDownvote()
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
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {}
                    
                    HStack {
                        if !hideNComments {
                            HStack() {
                                SwiftUI.Image(systemName: "text.bubble")
                                    .postIconTemplateRendering()
                                    .postIcon()
                                
                                Text(String(postViewModel.post.numComments))
                                    .postInfo()
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.leading, voteButtonsOnTheRight ? 8 : 16)
                    .environment(\.layoutDirection, .leftToRight)
                    
                    Button(action: {
                        saveTask?.cancel()
                        saveTask = Task {
                            await onToggleSave()
                        }
                    }) {
                        SwiftUI.Image(systemName: postViewModel.post.saved ? "bookmark.fill" : "bookmark")
                            .postIconTemplateRendering()
                            .postIcon()
                    }
                    .buttonStyle(.borderless)
                    .padding(8)
                    .contentShape(Rectangle())
                    
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
                .padding(.horizontal, 8)
                
                CustomDivider()
            }
        }
        .background {
            Rectangle()
                .fill(Color(hex: postViewModel.post.isRead ? themeViewModel.currentCustomTheme.readPostCardViewBackgroundColor : themeViewModel.currentCustomTheme.cardViewBackgroundColor))
        }
    }
}

private struct NoPreviewLinkView: View {
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            SwiftUI.Image(systemName: "link")
                .aspectRatio(contentMode: .fit)
                .clipped()
                .noPreviewPostTypeIndicator()
        }
        .noPreviewPostTypeIndicatorBackground()
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            onTap()
        }
    }
}
