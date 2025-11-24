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
    
    @StateObject var commentViewModel: CommentViewModel
    @State private var voteTask: Task<Void, Never>? = nil
    @State private var saveTask: Task<Void, Never>? = nil
    @State private var isToolbarHidden: Bool

    private let isInPostDetails: Bool
    private let userIconSize: CGFloat = 24
    let highlightComment: Bool
    let onToggleExpand: (() -> Void)?
    let onReply: (() -> Void)?
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onAddToCommentFilter: () -> Void
    
    init(
        account: Account,
        comment: Comment,
        isInPostDetails: Bool,
        highlightComment: Bool = false,
        onToggleExpand: (() -> Void)? = nil,
        onReply: (() -> Void)? = nil,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onAddToCommentFilter: @escaping () -> Void
    ) {
        self.isInPostDetails = isInPostDetails
        self.highlightComment = highlightComment
        self.onToggleExpand = onToggleExpand
        self.onReply = onReply
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onAddToCommentFilter = onAddToCommentFilter
        self.isToolbarHidden = isInPostDetails ? UserDefaults.interfaceComment.bool(forKey: InterfaceCommentUserDefaultsUtils.hideToolbarKey) : false
        _commentViewModel = StateObject(wrappedValue: CommentViewModel(account: account, comment: comment, commentRepository: CommentRepository()))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            CommentIndentationView(depth: commentViewModel.comment.depth)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    if isInPostDetails && showAuthorAvatar {
                        CustomWebImage(
                            commentViewModel.comment.authorIconUrl?.absoluteString,
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
                                .markdownImageProvider(WebImageProvider(mediaMetadata: commentViewModel.comment.mediaMetadata))
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                                .themedCommentMarkdown()
                                .markdownLinkHandler { url in
                                    navigationManager.openLink(url)
                                }
                        } else {
                            Markdown(commentViewModel.comment.body)
                                .markdownImageProvider(WebImageProvider(mediaMetadata: commentViewModel.comment.mediaMetadata))
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
                                    voteTask?.cancel()
                                    voteTask = Task {
                                        await commentViewModel.voteComment(vote: 1)
                                    }
                                }) {
                                    SwiftUI.Image(systemName: commentViewModel.comment.likes == 1 ? "arrowshape.up.fill" : "arrowshape.up")
                                        .commentIconTemplateRendering()
                                        .commentUpvoteIcon(isUpvoted: commentViewModel.comment.likes == 1)
                                }
                                .buttonStyle(.borderless)
                                .padding(8)
                                .contentShape(Rectangle())
                                .excludeFromTouchRipple()

                                VotesText(votes: commentViewModel.comment.score + commentViewModel.comment.likes, hideNVotes: hideNVotes)
                                    .frame(width: 72, alignment: .center)
                                    .commentInfo()
                                    .onTapGesture {}
                                
                                Button(action: {
                                    voteTask?.cancel()
                                    voteTask = Task {
                                        await commentViewModel.voteComment(vote: -1)
                                    }
                                }) {
                                    SwiftUI.Image(systemName: commentViewModel.comment.likes == -1 ? "arrowshape.down.fill" : "arrowshape.down")
                                        .commentIconTemplateRendering()
                                        .commentDownvoteIcon(isDownvoted: commentViewModel.comment.likes == -1)
                                }
                                .buttonStyle(.borderless)
                                .padding(8)
                                .contentShape(Rectangle())
                                .excludeFromTouchRipple()
                            }
                            .environment(\.layoutDirection, .leftToRight)
                            
                            Spacer()
                            
                            if commentViewModel.comment.depth < showFewerToolbarOptionsThreshold && isInPostDetails {
                                Menu {
                                    ShareLink(item: "https://reddit.com" + commentViewModel.comment.permalink) {
                                        Text("Share")
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
                                } label: {
                                    SwiftUI.Image(systemName: "ellipsis.circle")
                                        .commentIconTemplateRendering()
                                        .commentIcon()
                                }
                                .padding(8)
                                .excludeFromTouchRipple()
                                
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
                                
                                Button(action: {
                                    saveTask?.cancel()
                                    saveTask = Task {
                                        await commentViewModel.saveComment(save: !commentViewModel.comment.saved)
                                    }
                                }) {
                                    SwiftUI.Image(systemName: commentViewModel.comment.saved ? "bookmark.fill" : "bookmark")
                                        .commentIconTemplateRendering()
                                        .commentIcon()
                                }
                                .buttonStyle(.borderless)
                                .padding(8)
                                .contentShape(Rectangle())
                                
                                if isInPostDetails {
                                    Button(action: {
                                        onReply?()
                                    }) {
                                        SwiftUI.Image(systemName: "arrowshape.turn.up.left.fill")
                                            .commentIconTemplateRendering()
                                            .commentIcon()
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
                                    
                                    Button(commentViewModel.comment.saved ? "Unsave" : "Save") {
                                        saveTask?.cancel()
                                        saveTask = Task {
                                            await commentViewModel.saveComment(save: !commentViewModel.comment.saved)
                                        }
                                    }
                                    
                                    ShareLink(item: "https://reddit.com" + commentViewModel.comment.permalink) {
                                        Text("Share")
                                    }
                                    
                                    if isInPostDetails {
                                        Button("Reply") {
                                            onReply?()
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
                                } label: {
                                    SwiftUI.Image(systemName: "ellipsis.circle")
                                        .commentIconTemplateRendering()
                                        .commentIcon()
                                }
                                .padding(8)
                                .excludeFromTouchRipple()
                            }
                        }
                        .environment(\.layoutDirection, voteButtonsOnTheRight ? .rightToLeft : .leftToRight)
                        .padding(.horizontal, 8)
                    }
                }
                
                if showCommentDivider {
                    Divider()
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
