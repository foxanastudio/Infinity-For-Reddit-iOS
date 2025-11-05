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
                .frame(height: 16)
            
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
                    
                    HStack(spacing: 12) {
                        Label("\(postViewModel.post.score)", systemImage: "arrow.up")
                            .font(.caption)
                        Label("\(postViewModel.post.numComments)", systemImage: "bubble.left")
                            .font(.caption)
                        Spacer()
                    }
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
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
            .onAppear {
                print("Post: ", postViewModel.post.title ?? "")
                print("Post Type of \(postViewModel.post.title ?? ""): ", postViewModel.post.postType.text)
            }
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
