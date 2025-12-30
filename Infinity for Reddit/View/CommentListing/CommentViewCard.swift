//
//  CommentViewCard.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-17.
//

import SwiftUI
import SDWebImageSwiftUI
import MarkdownUI

struct CommentViewCard: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    @AppStorage(InterfaceCommentUserDefaultsUtils.showCommentDividerKey, store: .interfaceComment)
    private var showCommentDivider: Bool = false
    @AppStorage(InterfaceCommentUserDefaultsUtils.fullyCollapseCommentKey, store: .interfaceComment)
    private var fullyCollapseComment: Bool = false
    @AppStorage(InterfaceCommentUserDefaultsUtils.hideToolbarKey, store: .interfaceComment)
    private var hideToolbar: Bool = false
    @AppStorage(InterfaceCommentUserDefaultsUtils.hideNVotesKey, store: .interfaceComment)
    private var hideNVotes: Bool = false
    @AppStorage(InterfaceCommentUserDefaultsUtils.showAuthorAvatarKey, store: .interfaceComment)
    private var showAuthorAvatar: Bool = false
    @AppStorage(InterfaceCommentUserDefaultsUtils.showFewerToolbarOptionsThresholdKey, store: .interfaceComment)
    private var showFewerToolbarOptionsThreshold: Int = 5
    @AppStorage(InterfaceUserDefaultsUtils.voteButtonsOnTheRightKey, store: .interface)
    private var voteButtonsOnTheRight: Bool = false
    @AppStorage(InterfaceCommentUserDefaultsUtils.markdownEmbeddedMediaTypeKey, store: .interfaceComment) private var markdownEmbeddedMediaType: Int = 15
    
    @StateObject var commentViewModel: CommentViewModel
    @State private var voteTask: Task<Void, Never>? = nil
    @State private var saveTask: Task<Void, Never>? = nil
    @State private var isToolbarHidden: Bool

    private let isInPostDetails: Bool
    private let userIconSize: CGFloat = 24
    let highlightComment: Bool
    let onUpvote: () -> Void
    let onDownvote: () -> Void
    let onToggleSave: () -> Void
    let onToggleExpand: (() -> Void)?
    let onReply: (() -> Void)?
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onAddToCommentFilter: () -> Void
    let onModerate: () -> Void
    let onCopy: () -> Void
    
    init(
        comment: Comment,
        isInPostDetails: Bool,
        highlightComment: Bool = false,
        thingModerationRepository: ThingModerationRepositoryProtocol,
        onUpvote: @escaping () -> Void,
        onDownvote: @escaping () -> Void,
        onToggleSave: @escaping () -> Void,
        onToggleExpand: (() -> Void)? = nil,
        onReply: (() -> Void)? = nil,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onAddToCommentFilter: @escaping () -> Void,
        onModerate: @escaping () -> Void,
        onCopy: @escaping () -> Void
    ) {
        self.isInPostDetails = isInPostDetails
        self.highlightComment = highlightComment
        self.onUpvote = onUpvote
        self.onDownvote = onDownvote
        self.onToggleSave = onToggleSave
        self.onToggleExpand = onToggleExpand
        self.onReply = onReply
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onAddToCommentFilter = onAddToCommentFilter
        self.onModerate = onModerate
        self.onCopy = onCopy
        self.isToolbarHidden = isInPostDetails ? UserDefaults.interfaceComment.bool(forKey: InterfaceCommentUserDefaultsUtils.hideToolbarKey) : false
        _commentViewModel = StateObject(wrappedValue: CommentViewModel(comment: comment))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            CommentIndentationView(depth: commentViewModel.comment.depth)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    if isInPostDetails && showAuthorAvatar {
                        CustomWebImage(
                            commentViewModel.comment.authorIconUrlString,
                            width: userIconSize,
                            height: userIconSize,
                            circleClipped: true,
                            handleImageTapGesture: false,
                            fallbackView: {
                                InitialLetterAvatarImageFallbackView(name: commentViewModel.comment.author, size: userIconSize)
                            }
                        )
                        .frame(width: userIconSize, height: userIconSize)
                        .onTapGesture {
                            navigationManager.append(AppNavigation.userDetails(username: commentViewModel.comment.author))
                        }
                    }
                    
                    
                    if !isInPostDetails {
                        Text(commentViewModel.comment.subredditNamePrefixed)
                            .subreddit()
                            .onTapGesture {
                                navigationManager.append(AppNavigation.subredditDetails(subredditName: commentViewModel.comment.subreddit))
                            }
                    } else {
                        VStack(alignment: .leading, spacing: 0) {
                            CommentAuthorView(comment: commentViewModel.comment)
                                .id(commentViewModel.comment.author)
                            
                            AuthorFlairView(flairRichtext: commentViewModel.comment.authorFlairRichtext, flairText: commentViewModel.comment.authorFlairText)
                        }
                        .onTapGesture {
                            navigationManager.append(AppNavigation.userDetails(username: commentViewModel.comment.author))
                        }
                    }
                    
                    Spacer()
                    
                    TimeText(timeUTCInSeconds: commentViewModel.comment.createdUtc)
                        .secondaryText()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                if !((commentViewModel.comment.isCollasped && fullyCollapseComment && commentViewModel.comment.hasExpandedBefore) || (commentViewModel.comment.isFilteredOut && !commentViewModel.comment.hasExpandedBefore)) {
                    Group {
                        if let processedMarkdown = commentViewModel.comment.bodyProcessedMarkdown {
                            Markdown(processedMarkdown)
                                .markdownImageProvider(
                                    MarkdownImageProvider(
                                        mediaMetadata: commentViewModel.comment.mediaMetadata,
                                        markdownEmbeddedMediaType: markdownEmbeddedMediaType,
                                        isSensitive: commentViewModel.comment.over18,
                                        fontSize: .f15,
                                        linkColor: Color(hex: customThemeViewModel.currentCustomTheme.linkColor),
                                        fullScreenMediaViewModel: fullScreenMediaViewModel,
                                        onLinkTap: { url in
                                            navigationManager.openLink(url)
                                        }
                                    )
                                )
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                                .themedCommentMarkdown()
                                .markdownLinkHandler { url in
                                    navigationManager.openLink(url)
                                }
                        } else {
                            Markdown(commentViewModel.comment.body)
                                .markdownImageProvider(
                                    MarkdownImageProvider(
                                        mediaMetadata: commentViewModel.comment.mediaMetadata,
                                        markdownEmbeddedMediaType: markdownEmbeddedMediaType,
                                        isSensitive: commentViewModel.comment.over18,
                                        fontSize: .f15,
                                        linkColor: Color(hex: customThemeViewModel.currentCustomTheme.linkColor),
                                        fullScreenMediaViewModel: fullScreenMediaViewModel,
                                        onLinkTap: { url in
                                            navigationManager.openLink(url)
                                        }
                                    )
                                )
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                                .themedCommentMarkdown()
                                .markdownLinkHandler { url in
                                    navigationManager.openLink(url)
                                }
                        }
                    }
                    
                    if !isToolbarHidden {
                        HStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Button(action: {
                                    onUpvote()
                                }) {
                                    SwiftUI.Image(systemName: commentViewModel.comment.likes == 1 ? "arrowshape.up.fill" : "arrowshape.up")
                                        .commentIconTemplateRendering()
                                        .commentUpvoteIcon(isUpvoted: commentViewModel.comment.likes == 1)
                                }
                                .buttonStyle(.borderless)
                                .padding(8)
                                .contentShape(Rectangle())

                                VotesText(votes: commentViewModel.comment.score + commentViewModel.comment.likes, hideNVotes: hideNVotes)
                                    .frame(width: 72, alignment: .center)
                                    .commentInfo()
                                    .onTapGesture {}
                                
                                Button(action: {
                                    onDownvote()
                                }) {
                                    SwiftUI.Image(systemName: commentViewModel.comment.likes == -1 ? "arrowshape.down.fill" : "arrowshape.down")
                                        .commentIconTemplateRendering()
                                        .commentDownvoteIcon(isDownvoted: commentViewModel.comment.likes == -1)
                                }
                                .buttonStyle(.borderless)
                                .padding(8)
                                .contentShape(Rectangle())
                            }
                            .environment(\.layoutDirection, .leftToRight)
                            
                            Spacer()
                            
                            if commentViewModel.comment.depth < showFewerToolbarOptionsThreshold && isInPostDetails {
                                Menu {
                                    ShareLink(item: "https://reddit.com" + commentViewModel.comment.permalink) {
                                        Text("Share")
                                    }
                                    
                                    Button("Copy") {
                                        onCopy()
                                    }
                                    
                                    if accountViewModel.account.username == commentViewModel.comment.author {
                                        Button("Edit") {
                                            onEdit()
                                        }
                                        
                                        Button("Delete") {
                                            onDelete()
                                        }
                                    }
                                    
                                    Button("Add to Comment Filter") {
                                        onAddToCommentFilter()
                                    }
                                    
                                    Button("Report") {
                                        if accountViewModel.account.isAnonymous() {
                                            navigationManager.openLink("https://www.reddit.com/report")
                                        } else {
                                            navigationManager.append(AppNavigation.report(subredditName: commentViewModel.comment.subreddit, thingFullname: commentViewModel.comment.name))
                                        }
                                    }
                                    
                                    if commentViewModel.comment.canModComment {
                                        Button("Moderate") {
                                            onModerate()
                                        }
                                    }
                                } label: {
                                    SwiftUI.Image(systemName: "ellipsis.circle")
                                        .commentIconTemplateRendering()
                                        .commentIcon()
                                }
                                .padding(8)
                                
                                if let onToggleExpand, commentViewModel.comment.hasReplies {
                                    Button(action: {
                                        onToggleExpand()
                                    }) {
                                        SwiftUI.Image(systemName: "chevron.up")
                                            .commentIconTemplateRendering()
                                            .commentIcon()
                                            .rotationEffect(.degrees(commentViewModel.comment.isCollasped ? 180 : 0))
                                            .animation(.easeInOut(duration: 0.25), value: commentViewModel.comment.isCollasped)
                                    }
                                    .buttonStyle(.borderless)
                                    .padding(8)
                                    .contentShape(Rectangle())
                                }
                                
                                if !accountViewModel.account.isAnonymous() {
                                    Button(action: {
                                        onToggleSave()
                                    }) {
                                        SwiftUI.Image(systemName: commentViewModel.comment.saved ? "bookmark.fill" : "bookmark")
                                            .commentIconTemplateRendering()
                                            .commentIcon()
                                    }
                                    .buttonStyle(.borderless)
                                    .padding(8)
                                    .contentShape(Rectangle())
                                }
                                
                                if isInPostDetails && !accountViewModel.account.isAnonymous() {
                                    Button(action: {
                                        if commentViewModel.comment.locked {
                                            snackbarManager.showSnackbar(.info("This comment is locked."))
                                        } else {
                                            onReply?()
                                        }
                                    }) {
                                        SwiftUI.Image(systemName: "arrowshape.turn.up.left.fill")
                                            .commentIconTemplateRendering()
                                            .applyIf(commentViewModel.comment.locked) {
                                                $0.voteAndReplyUnavailbleIcon()
                                            }
                                            .applyIf(!commentViewModel.comment.locked) {
                                                $0.commentIcon()
                                            }
                                    }
                                    .buttonStyle(.borderless)
                                    .padding(8)
                                    .contentShape(Rectangle())
                                }
                            } else {
                                Menu {
                                    if let onToggleExpand, commentViewModel.comment.hasReplies {
                                        Button(commentViewModel.comment.isCollasped ? "Expand" : "Collapse") {
                                            onToggleExpand()
                                        }
                                    }
                                    
                                    if !accountViewModel.account.isAnonymous() {
                                        Button(commentViewModel.comment.saved ? "Unsave" : "Save") {
                                            onToggleSave()
                                        }
                                    }
                                    
                                    ShareLink(item: "https://reddit.com" + commentViewModel.comment.permalink) {
                                        Text("Share")
                                    }
                                    
                                    Button("Copy") {
                                        onCopy()
                                    }
                                    
                                    if isInPostDetails && !accountViewModel.account.isAnonymous() {
                                        Button("Reply") {
                                            if commentViewModel.comment.locked {
                                                snackbarManager.showSnackbar(.info("This comment is locked."))
                                            } else {
                                                onReply?()
                                            }
                                        }
                                    }
                                    
                                    if accountViewModel.account.username == commentViewModel.comment.author {
                                        Button("Edit") {
                                            onEdit()
                                        }
                                        
                                        Button("Delete") {
                                            onDelete()
                                        }
                                    }
                                    
                                    Button("Add to Comment Filter") {
                                        onAddToCommentFilter()
                                    }
                                    
                                    Button("Report") {
                                        if accountViewModel.account.isAnonymous() {
                                            navigationManager.openLink("https://www.reddit.com/report")
                                        } else {
                                            navigationManager.append(AppNavigation.report(subredditName: commentViewModel.comment.subreddit, thingFullname: commentViewModel.comment.name))
                                        }
                                    }
                                    
                                    if commentViewModel.comment.canModComment {
                                        Button("Moderate") {
                                            onModerate()
                                        }
                                    }
                                } label: {
                                    SwiftUI.Image(systemName: "ellipsis.circle")
                                        .commentIconTemplateRendering()
                                        .commentIcon()
                                }
                                .padding(8)
                            }
                        }
                        .environment(\.layoutDirection, voteButtonsOnTheRight ? .rightToLeft : .leftToRight)
                        .padding(.horizontal, 8)
                    }
                }
                
                if showCommentDivider {
                    CustomDivider()
                }
            }
        }
        .contentShape(Rectangle())
        .background(backgroundColor)
        .applyIf(isInPostDetails) {
            $0.onTapGesture {
                isToolbarHidden.toggle()
            }
        }
    }
    
    private var backgroundColor: Color {
        return (commentViewModel.comment.isCollasped && fullyCollapseComment && commentViewModel.comment.hasExpandedBefore)
        || (commentViewModel.comment.isFilteredOut && !commentViewModel.comment.hasExpandedBefore) ? Color(hex: customThemeViewModel.currentCustomTheme.fullyCollapsedCommentBackgroundColor)
        : (highlightComment ? Color(hex: customThemeViewModel.currentCustomTheme.singleCommentThreadBackgroundColor) : Color.clear)
    }
}
