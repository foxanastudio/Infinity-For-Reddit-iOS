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
    
    @StateObject var postViewModel: PostViewModel
    @State var voteTask: Task<Void, Never>?
    @State var saveTask: Task<Void, Never>?
    
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSensitiveImagesKey, store: .contentSensitivityFilter) private var blurSensitiveImages: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSpoilerImagesKey, store: .contentSensitivityFilter) private var blurSpoilerImages: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.showPostAndCommentsInTwoColumnsInLandscapeKey, store: .interfacePostDetails) private var showPostAndCommentsInTwoColumnsInLandscape: Bool = true
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hidePostTypeKey, store: .interfacePostDetails) private var hidePostType: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hidePostFlairKey, store: .interfacePostDetails) private var hidePostFlair: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hideUpvoteRatioKey, store: .interfacePostDetails) private var hideUpvoteRatio: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hideSubredditAndUserPrefixKey, store: .interfacePostDetails) private var hideSubredditAndUserPrefix: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hideNVotesKey, store: .interfacePostDetails) private var hideNVotes: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hideNCommentsKey, store: .interfacePostDetails) private var hideNComments: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.markdownEmbeddedMediaTypeKey, store: .interfacePostDetails) private var markdownEmbeddedMediaType: Int = 15
    @AppStorage(InterfaceUserDefaultsUtils.voteButtonsOnTheRightKey, store: .interface) private var voteButtonsOnTheRight: Bool = false

    let isFromSubredditPostListing: Bool
    let onSendComment: () -> Void
    
    private let iconSize: CGFloat = 24
    
    init(account: Account, post: Post, isFromSubredditPostListing: Bool, onSendComment: @escaping () -> Void) {
        self.isFromSubredditPostListing = isFromSubredditPostListing
        self.onSendComment = onSendComment
        _postViewModel = StateObject(wrappedValue: PostViewModel(account: account, post: post, postRepository: PostRepository()))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: 16)
            
            HStack {
                CustomWebImage(
                    postViewModel.post.subredditOrUserIconInPostDetails,
                    width: iconSize,
                    height: iconSize,
                    circleClipped: true,
                    handleImageTapGesture: false,
                    fallbackView: {
                        InitialLetterAvatarImageFallbackView(name: postViewModel.post.subreddit, size: iconSize)
                    }
                )
                .frame(width: iconSize, height: iconSize)
                .onTapGesture {
                    goToSubredditDetails()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(hideSubredditAndUserPrefix ? postViewModel.post.subreddit : postViewModel.post.subredditNamePrefixed)
                        .subreddit()
                        .onTapGesture {
                            goToSubredditDetails()
                        }
                    
                    Text(hideSubredditAndUserPrefix ? postViewModel.post.author : "u/\(postViewModel.post.author ?? "")")
                        .usernameOnPost(post: postViewModel.post)
                        .onTapGesture {
                            goToUserDetails()
                        }
                    
                    AuthorFlairView(flairRichtext: postViewModel.post.authorFlairRichtext, flairText: postViewModel.post.authorFlairText)
                        .padding(.top, 4)
                        .onTapGesture {
                            goToUserDetails()
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
                && hideUpvoteRatio && !postViewModel.post.archived
                && !postViewModel.post.locked && postViewModel.post.crosspostParent == nil
                && postViewModel.post.postType != .link {
                // Not showing post metadata
                EmptyView()
            } else {
                HFlow(alignment: .center) {
                    if !hidePostType {
                        PostTypeTag(post: postViewModel.post)
                            .onTapGesture {
                                navigationManager.append(
                                    AppNavigation.filteredPosts(
                                        postListingMetadata: PostListingMetadata.getSubredditMetadadata(
                                            subredditName: postViewModel.post.subreddit, accountViewModel: accountViewModel
                                        ),
                                        postFilter: PostFilter.constructPostFilter(postType: postViewModel.post.postType)
                                    )
                                )
                            }
                    }
                    
                    if postViewModel.post.spoiler {
                        SpoilerTag()
                    }
                    
                    if postViewModel.post.over18 {
                        SensitiveTag()
                            .onTapGesture {
                                var postFilter = PostFilter()
                                postFilter.onlySensitive = true
                                navigationManager.append(
                                    AppNavigation.filteredPosts(
                                        postListingMetadata: PostListingMetadata.getSubredditMetadadata(
                                            subredditName: postViewModel.post.subreddit, accountViewModel: accountViewModel
                                        ),
                                        postFilter: postFilter
                                    )
                                )
                            }
                    }
                    
                    if !hidePostFlair {
                        FlairView(flairRichtext: postViewModel.post.linkFlairRichtext,
                                  flairText: postViewModel.post.linkFlairText)
                    }
                    
                    if !hideUpvoteRatio {
                        UpvoteRatioTag(post: postViewModel.post)
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
                        navigationManager.openLink(url)
                    }
                } else if let crosspost = postViewModel.post.crosspostParent, let url = URL(string: crosspost.url), let domain = url.host {
                    NoPreviewLinkView(domain: domain) {
                        navigationManager.openLink(url)
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
            } else if case .redditVideo(let videoUrlString, _) = postViewModel.post.postType {
                Spacer()
                    .frame(height: 10)
                
                PostVideoView(post: postViewModel.post, videoUrlString: videoUrlString)
            } else if case .video(let videoUrlString, _) = postViewModel.post.postType {
                Spacer()
                    .frame(height: 10)
                
                PostVideoView(post: postViewModel.post, videoUrlString: videoUrlString)
            } else if postViewModel.post.postType.isMedia {
                Spacer()
                    .frame(height: 10)
                
                PostPreviewView(post: postViewModel.post)
            }
            
            if let selftext = postViewModel.post.selftextProcessedMarkdown {
                Markdown(selftext)
                    .markdownImageProvider(WebImageProvider(mediaMetadata: postViewModel.post.mediaMetadata))
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .themedPostCommentMarkdown()
                    .markdownLinkHandler { url in
                        navigationManager.openLink(url)
                    }
            }
            
            HStack(spacing: 0) {
                HStack(spacing: 0) {
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
                    .padding(8)
                    .contentShape(Rectangle())
                    
                    VotesText(votes: accountViewModel.account.isAnonymous() ? postViewModel.post.score : postViewModel.post.score + postViewModel.post.likes, hideNVotes: hideNVotes)
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
                            Text(String(postViewModel.post.numComments))
                                .postInfo()
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSendComment()
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
            .padding(8)
        }
        .padding(.vertical, 0)
    }
    
    private func goToSubredditDetails() {
        navigationManager.append(AppNavigation.subredditDetails(subredditName: postViewModel.post.subreddit))
    }
    
    private func goToUserDetails() {
        navigationManager.append(AppNavigation.userDetails(username: postViewModel.post.author))
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
