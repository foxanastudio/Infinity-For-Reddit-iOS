//
// PostView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-11-01

import SwiftUI

struct PostView: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var themeViewModel: CustomThemeViewModel
    
    @StateObject private var postViewModel: PostViewModel
    
    let post: Post
    let layout: PostLayoutType
    let isSubredditPostListing: Bool
    
    // Callback closures
    let onPostTypeTap: () -> Void
    let onSensitiveTap: () -> Void
    
    // MARK: - Init
    init(
        account: Account,
        post: Post,
        layout: PostLayoutType,
        isSubredditPostListing: Bool,
        onPostTypeTap: @escaping () -> Void,
        onSensitiveTap: @escaping () -> Void
    ) {
        self.post = post
        self.layout = layout
        self.isSubredditPostListing = isSubredditPostListing
        self.onPostTypeTap = onPostTypeTap
        self.onSensitiveTap = onSensitiveTap
        _postViewModel = StateObject(
            wrappedValue: PostViewModel(
                account: account,
                post: post,
                postRepository: PostRepository()
            )
        )
    }
    
    // MARK: - Body
    var body: some View {
        switch layout {
        case .card:
            PostViewCard(
                postViewModel: postViewModel,
                isSubredditPostListing: isSubredditPostListing,
                onPostTap: handlePostTap,
                onIconTap: handleIconTap,
                onSubredditTap: handleSubredditTap,
                onUserTap: handleUserTap,
                onVote: handleVote,
                onCommentsTap: handleCommentsTap,
                onSave: handleSave,
                onShare: handleShare,
                onPostTypeClicked: onPostTypeTap,
                onSensitiveClicked: onSensitiveTap,
                onOpenLink: handleOpenLink
            )
            
        case .compact:
            PostViewCompact()
        }
    }
}

// MARK: - Interaction & Task Handlers
extension PostView {
    
    private func handlePostTap() {
        Task { await postViewModel.readPost() }
        navigationManager.path.append(
            AppNavigation.postDetails(
                postDetailsInput: .post(post),
                isFromSubredditPostListing: isSubredditPostListing
            )
        )
    }
    
    private func handleIconTap(_ post: Post) {
        if !isSubredditPostListing {
            navigationManager.path.append(
                AppNavigation.subredditDetails(subredditName: post.subreddit)
            )
        } else if !post.isAuthorDeleted() {
            navigationManager.path.append(
                AppNavigation.userDetails(username: post.author)
            )
        }
    }
    
    private func handleSubredditTap(_ post: Post) {
        navigationManager.path.append(
            AppNavigation.subredditDetails(subredditName: post.subreddit)
        )
    }
    
    private func handleUserTap(_ post: Post) {
        navigationManager.path.append(
            AppNavigation.userDetails(username: post.author)
        )
    }
    
    private func handleVote(_ direction: Int) {
        guard !accountViewModel.account.isAnonymous() else { return }
        Task {
            await postViewModel.votePost(vote: direction)
        }
    }
    
    private func handleSave() {
        Task {
            await postViewModel.savePost(save: !postViewModel.post.saved)
        }
    }
    
    private func handleCommentsTap() {
        // TODO: Open post details and focus on comments section.
    }
    
    
    private func handleShare() {
        // Reserved for future custom share sheet logic.
    }
    
    private func handleOpenLink(_ url: URL) {
        navigationManager.openLink(url)
        Task { await postViewModel.readPost() }
    }
}
