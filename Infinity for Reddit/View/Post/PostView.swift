//
//  PostView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-11-01.
//

import SwiftUI

struct PostView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    //@StateObject private var postViewModel: PostViewModel
    
    let post: Post
    let postLayout: PostLayout
    let iconType: IconType
    let postFeedScrollIdle: Bool
    let postFeedGeometry: GeometryProxy
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
        iconType: IconType,
        postFeedScrollIdle: Bool,
        postFeedGeometry: GeometryProxy,
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
        self.iconType = iconType
        self.postFeedScrollIdle = postFeedScrollIdle
        self.postFeedGeometry = postFeedGeometry
        self.onUpvote = onUpvote
        self.onDownvote = onDownvote
        self.onToggleSave = onToggleSave
        self.onPostTypeTap = onPostTypeTap
        self.onSensitiveTap = onSensitiveTap
        self.onLongPressPost = onLongPressPost
        self.onShare = onShare
        self.onReadPost = onReadPost
//        _postViewModel = StateObject(
//            wrappedValue: PostViewModel(
//                post: post,
//                postRepository: PostRepository()
//            )
//        )
    }

    var body: some View {
        Group {
            switch postLayout {
            case .card:
                PostViewCard(
                    //postViewModel: postViewModel,
                    post: post,
                    iconType: iconType,
                    postFeedScrollIdle: postFeedScrollIdle,
                    postFeedGeometry: postFeedGeometry,
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
                    //postViewModel: postViewModel,
                    post: post,
                    iconType: iconType,
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
            await onReadPost()
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
        if iconType == .subreddit {
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
            await onReadPost()
        }
    }
}
