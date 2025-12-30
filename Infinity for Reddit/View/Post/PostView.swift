//
//  PostView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-11-01.
//

import SwiftUI

struct PostView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @StateObject private var postViewModel: PostViewModel
    
    @AppStorage(PostHistoryUserDefaultsUtils.markPostsAsReadKey, store: .postHistory) private var markPostsAsRead: Bool = false
    @AppStorage(PostHistoryUserDefaultsUtils.limitReadPostsKey, store: .postHistory) private var limitReadPosts: Bool = true
    @AppStorage(PostHistoryUserDefaultsUtils.readPostsLimitKey, store: .postHistory) private var readPostsLimit: Int = 500
    
    let post: Post
    let postLayout: PostLayout
    let isSubredditPostListing: Bool
    let onUpvote: () async -> Void
    let onDownvote: () async -> Void
    let onToggleSave: () async -> Void
    let onPostTypeTap: () -> Void
    let onSensitiveTap: () -> Void
    let onLongPressPost: () -> Void
    let onShare: () -> Void
    let onReadPost: () async -> Void

    init(
        post: Post,
        postLayout: PostLayout,
        isSubredditPostListing: Bool,
        onUpvote: @escaping () async -> Void,
        onDownvote: @escaping () async -> Void,
        onToggleSave: @escaping () async -> Void,
        onPostTypeTap: @escaping () -> Void,
        onSensitiveTap: @escaping () -> Void,
        onLongPressPost: @escaping () -> Void,
        onShare: @escaping () -> Void,
        onReadPost: @escaping () async -> Void
    ) {
        self.post = post
        self.postLayout = postLayout
        self.isSubredditPostListing = isSubredditPostListing
        self.onUpvote = onUpvote
        self.onDownvote = onDownvote
        self.onToggleSave = onToggleSave
        self.onPostTypeTap = onPostTypeTap
        self.onSensitiveTap = onSensitiveTap
        self.onLongPressPost = onLongPressPost
        self.onShare = onShare
        self.onReadPost = onReadPost
        _postViewModel = StateObject(
            wrappedValue: PostViewModel(
                post: post,
                postRepository: PostRepository()
            )
        )
    }

    var body: some View {
        Group {
            switch postLayout {
            case .card:
                PostViewCard(
                    postViewModel: postViewModel,
                    isSubredditPostListing: isSubredditPostListing,
                    onPostTap: { videoPlaybackTime in
                        onPostTap(videoPlaybackTime)
                    },
                    onIconTap: onIconTap,
                    onSubredditTap: onSubredditTap,
                    onUserTap: onUserTap,
                    onUpvote: onUpvote,
                    onDownvote: onDownvote,
                    onCommentsTap: onCommentsTap,
                    onToggleSave: onToggleSave,
                    onPostTypeClicked: onPostTypeTap,
                    onSensitiveClicked: onSensitiveTap,
                    onOpenLink: openLink,
                    onShare: onShare,
                    onReadPost: onReadPost,
                    onLongPressPost: onLongPressPost
                )
            case .compact:
                PostViewCompact(
                    postViewModel: postViewModel,
                    isSubredditPostListing: isSubredditPostListing,
                    onPostTap: {
                        onPostTap(0)
                    },
                    onIconTap: onIconTap,
                    onSubredditTap: onSubredditTap,
                    onUserTap: onUserTap,
                    onUpvote: onUpvote,
                    onDownvote: onDownvote,
                    onCommentsTap: onCommentsTap,
                    onToggleSave: onToggleSave,
                    onPostTypeClicked: onPostTypeTap,
                    onSensitiveClicked: onSensitiveTap,
                    onOpenLink: openLink,
                    onShare: onShare,
                    onReadPost: onReadPost,
                    onLongPressPost: onLongPressPost
                )
            }
        }
        .frame(maxWidth: 500)
    }
    
    private func onPostTap(_ videoPlaybackTime: Double) {
        Task {
            await postViewModel.readPost(markPostsAsRead: markPostsAsRead, limitReadPosts: limitReadPosts, readPostsLimit: readPostsLimit)
        }
        
        navigationManager.append(
            AppNavigation.postDetails(
                postDetailsInput: .post(post),
                isFromSubredditPostListing: isSubredditPostListing,
                videoPlaybackTime: videoPlaybackTime
            )
        )
    }
    
    private func onIconTap() {
        if !isSubredditPostListing {
            navigationManager.append(
                AppNavigation.subredditDetails(subredditName: post.subreddit)
            )
        } else if !post.isAuthorDeleted() {
            navigationManager.append(
                AppNavigation.userDetails(username: post.author)
            )
        }
    }
    
    private func onSubredditTap() {
        navigationManager.append(
            AppNavigation.subredditDetails(subredditName: post.subreddit)
        )
    }
    
    private func onUserTap() {
        navigationManager.append(
            AppNavigation.userDetails(username: post.author)
        )
    }
    
    private func onCommentsTap() {
        // TODO: Open post details and focus on comments section.
    }
    
    private func openLink(_ url: URL) {
        navigationManager.openLink(url)
        Task {
            await postViewModel.readPost(markPostsAsRead: markPostsAsRead, limitReadPosts: limitReadPosts, readPostsLimit: readPostsLimit)
        }
    }
}
