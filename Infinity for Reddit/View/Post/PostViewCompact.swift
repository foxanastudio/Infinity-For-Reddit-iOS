//
// PostViewCompact.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-10-30

import SwiftUI
import Flow

struct PostViewCompact: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var themeViewModel: CustomThemeViewModel
    
    @StateObject var postViewModel: PostViewModel
    @State private var voteTask: Task<Void, Never>?
    @State private var saveTask: Task<Void, Never>?
    
    // MARK: - User Preferences
    @AppStorage(InterfacePostUserDefaultsUtils.hidePostTypeKey, store: .interfacePost) private var hidePostType: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hidePostFlairKey, store: .interfacePost) private var hidePostFlair: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideSubredditAndUserPrefixKey, store: .interfacePost) private var hideSubredditAndUserPrefix: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideNVotesKey, store: .interfacePost) private var hideNVotes: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideNCommentsKey, store: .interfacePost) private var hideNComments: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.hideTextPostContentKey, store: .interfacePost) private var hideTextPostContent: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.limitMediaHeightKey, store: .interfacePost) private var limitMediaHeight: Bool = false
    @AppStorage(InterfaceUserDefaultsUtils.voteButtonsOnTheRightKey, store: .interface) private var voteButtonsOnTheRight: Bool = false
    
    @State var width: CGFloat?
    
    // MARK: - Layout Context
    let isSubredditPostListing: Bool
    
    // MARK: - External Callbacks
    let onPostTap: () -> Void
    let onIconTap: (_ post: Post) -> Void
    let onSubredditTap: (_ post: Post) -> Void
    let onUserTap: (_ post: Post) -> Void
    let onVote: (_ direction: Int) -> Void
    let onCommentsTap: () -> Void
    let onSave: () -> Void
    let onShare: () -> Void
    let onPostTypeClicked: () -> Void
    let onSensitiveClicked: () -> Void
    let onOpenLink: (_ url: URL) -> Void
    
    // MARK: - Constants
    private let iconSize: CGFloat = 24
    
    // MARK: - Initializer
    init(
        postViewModel: PostViewModel,
        isSubredditPostListing: Bool,
        width: CGFloat? = nil,
        onPostTap: @escaping () -> Void,
        onIconTap: @escaping (_ post: Post) -> Void,
        onSubredditTap: @escaping (_ post: Post) -> Void,
        onUserTap: @escaping (_ post: Post) -> Void,
        onVote: @escaping (_ direction: Int) -> Void,
        onCommentsTap: @escaping () -> Void,
        onSave: @escaping () -> Void,
        onShare: @escaping () -> Void,
        onPostTypeClicked: @escaping () -> Void,
        onSensitiveClicked: @escaping () -> Void,
        onOpenLink: @escaping (_ url: URL) -> Void
    ) {
        self._postViewModel = StateObject(wrappedValue: postViewModel)
        self.isSubredditPostListing = isSubredditPostListing
        self.width = width
        self.onPostTap = onPostTap
        self.onIconTap = onIconTap
        self.onSubredditTap = onSubredditTap
        self.onUserTap = onUserTap
        self.onVote = onVote
        self.onCommentsTap = onCommentsTap
        self.onSave = onSave
        self.onShare = onShare
        self.onPostTypeClicked = onPostTypeClicked
        self.onSensitiveClicked = onSensitiveClicked
        self.onOpenLink = onOpenLink
    }
    
    var body: some View {
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
                .onTapGesture { onIconTap(postViewModel.post) }
                
                Text(hideSubredditAndUserPrefix ? postViewModel.post.subreddit : postViewModel.post.subredditNamePrefixed)
                    .subreddit()
                    .onTapGesture {
                        onSubredditTap(postViewModel.post)
                    }
                .padding(.leading, 4)
                
                Spacer()
                
                TimeText(timeUTCInSeconds: postViewModel.post.createdUtc)
                    .secondaryText()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            HStack (alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(postViewModel.post.title)
                        .font(.system(size: 18))
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
                        NoPreviewLinkView(domain: domain) {
                            onOpenLink(url)
                            Task {
                                await postViewModel.readPost()
                            }
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
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
                   !galleryData.items.isEmpty {
                    GalleryCarousel(post: postViewModel.post, compactMode: true) {
                        Task {
                            await postViewModel.readPost()
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if !hideTextPostContent, case .text = postViewModel.post.postType, let selftextTruncated = postViewModel.post.selftextTruncated, !selftextTruncated.isEmpty {
                    Spacer()
                        .frame(height: 6)
                    
                    Text(selftextTruncated)
                        .postContent()
                        .padding(.horizontal, 16)
                } else if case .redditVideo(let videoUrlString, _) = postViewModel.post.postType {
                    PostVideoView(post: postViewModel.post, videoUrlString: videoUrlString, inPostListing: true, compactMode: true) {
                        Task {
                            await postViewModel.readPost()
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if case .video(let videoUrlString, _) = postViewModel.post.postType {
                    PostVideoView(post: postViewModel.post, videoUrlString: videoUrlString, inPostListing: true, compactMode: true) {
                        Task {
                            await postViewModel.readPost()
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if postViewModel.post.postType.isMedia {
                    PostPreviewView(post: postViewModel.post, inPostListing: true, compactMode: true) {
                        Task {
                            await postViewModel.readPost()
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if case .text = postViewModel.post.postType {
                    EmptyView()
                }
            }
            .padding(.horizontal, 16)
//            .onAppear {
//                print("Post: ", postViewModel.post.title ?? "")
//                print("Post Type of \(postViewModel.post.title ?? ""): ", postViewModel.post.postType.text)
//            }
            
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        onVote(1)
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
                        onVote(-1)
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
                .padding(.leading, 16)
                .environment(\.layoutDirection, .leftToRight)
                
                Button(action: onSave) {
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
            
            Divider()
        }
        .background {
            TouchRipple(backgroundShape: Rectangle()) {
                Rectangle()
                    .fill(Color(hex: postViewModel.post.isRead ? themeViewModel.currentCustomTheme.readPostCardViewBackgroundColor : themeViewModel.currentCustomTheme.cardViewBackgroundColor))
            }
        }
        .onTapGesture {
            onPostTap()
        }
    }
}

private struct NoPreviewLinkView: View {
    let domain: String
    let onTap: () -> Void
    
    var body: some View {
//        Spacer()
//            .frame(height: 10)
        
        Text(domain)
            .noPreviewPostTypeIndicatorBackground()
            .noPreviewPostTypeIndicator()
            .onTapGesture {
                onTap()
            }
    }
}
