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
    
    @AppStorage(PostHistoryUserDefaultsUtils.saveReadPostsKey, store: .postHistory) private var saveReadPosts: Bool = false
    @AppStorage(PostHistoryUserDefaultsUtils.limitHistorySizeKey, store: .postHistory) private var limitHistorySize: Bool = true
    @AppStorage(PostHistoryUserDefaultsUtils.historyLimitKey, store: .postHistory) private var historyLimit: Int = 500
    
    let post: Post
    let postLayout: PostLayout
    let displaySubredditIcon: Bool
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
        displaySubredditIcon: Bool,
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
        self.displaySubredditIcon = displaySubredditIcon
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
                    displaySubredditIcon: displaySubredditIcon,
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
                    displaySubredditIcon: displaySubredditIcon,
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
    }
    
    private func onPostTap(_ videoPlaybackTime: Double) {
        Task {
            await postViewModel.readPost(markPostsAsRead: saveReadPosts, limitHistorySize: limitHistorySize, historyLimit: historyLimit)
        }
        
        navigationManager.append(
            AppNavigation.postDetails(
                postDetailsInput: .post(post),
                //isFromSubredditPostListing: isSubredditPostListing,
                videoPlaybackTime: videoPlaybackTime
            )
        )
    }
    
    private func onIconTap() {
        if displaySubredditIcon {
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
            await postViewModel.readPost(markPostsAsRead: saveReadPosts, limitHistorySize: limitHistorySize, historyLimit: historyLimit)
        }
    }
}
