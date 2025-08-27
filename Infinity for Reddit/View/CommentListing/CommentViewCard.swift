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
    @EnvironmentObject var customThemeViewModel: CustomThemeViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    
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
    
    @StateObject var commentViewModel: CommentViewModel
    @State private var voteTask: Task<Void, Never>? = nil
    @State private var saveTask: Task<Void, Never>? = nil
    @State private var isToolbarHidden: Bool
    
    let formatter = DateFormatter()
    private let isInPostDetails: Bool
    let onToggleExpand: (() -> Void)?
    let onReply: (() -> Void)?
    
    init(account: Account, comment: Comment, isInPostDetails: Bool, onToggleExpand: (() -> Void)? = nil, onReply: (() -> Void)? = nil) {
        formatter.dateFormat = "y-MM-dd H:mm"
        self.isInPostDetails = isInPostDetails
        self.onToggleExpand = onToggleExpand
        self.onReply = onReply
        self.isToolbarHidden = UserDefaults.interfaceComment.bool(forKey: InterfaceCommentUserDefaultsUtils.hideToolbarKey)
        _commentViewModel = StateObject(wrappedValue: CommentViewModel(account: account, comment: comment, commentRepository: CommentRepository()))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            CommentIndentationView(depth: commentViewModel.comment.depth)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    if isInPostDetails && showAuthorAvatar {
                        CustomWebImage(
                            commentViewModel.comment.authorIconUrl?.absoluteString,
                            width: 24,
                            height: 24,
                            circleClipped: true,
                            handleImageTapGesture: false,
                            fallbackView: {
                                SwiftUI.Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        )
                        .frame(width: 24, height: 24)
                        .onTapGesture {
                            navigationManager.path.append(AppNavigation.userDetails(username: commentViewModel.comment.author))
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        if !isInPostDetails {
                            Text(commentViewModel.comment.subredditNamePrefixed)
                                .subreddit()
                                .onTapGesture {
                                    navigationManager.path.append(AppNavigation.subredditDetails(subredditName: commentViewModel.comment.subreddit))
                                }
                        } else {
                            Text("u/\(commentViewModel.comment.author)")
                                .username()
                                .onTapGesture {
                                    navigationManager.path.append(AppNavigation.userDetails(username: commentViewModel.comment.author))
                                }
                        }
                    }
                    
                    Spacer()
                    
                    Text(
                        formatter.string(from: Date(timeIntervalSince1970: TimeInterval(commentViewModel.comment.createdUtc)))
                    )
                    .secondaryText()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                if !((commentViewModel.comment.isCollasped && fullyCollapseComment && commentViewModel.comment.hasExpandedBefore) || (commentViewModel.comment.isFilteredOut && !commentViewModel.comment.hasExpandedBefore)) {
                    Group {
                        if let processedMarkdown = commentViewModel.comment.bodyProcessedMarkdown {
                            Markdown(processedMarkdown)
                                .markdownImageProvider(WebImageProvider(mediaMetadata: commentViewModel.comment.mediaMetadata))
                                .font(.system(size: 24))
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                                .themedCommentMarkdown()
                                .markdownLinkHandler { url in
                                    LinkHandler.shared.handle(url: url)
                                }
                                .id(commentViewModel.comment.id)
                        } else {
                            Markdown(commentViewModel.comment.body)
                                .markdownImageProvider(WebImageProvider(mediaMetadata: commentViewModel.comment.mediaMetadata))
                                .font(.system(size: 24))
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                                .themedCommentMarkdown()
                                .markdownLinkHandler { url in
                                    LinkHandler.shared.handle(url: url)
                                }
                                .id(commentViewModel.comment.id)
                        }
                    }
                    
                    if !isToolbarHidden {
                        HStack(alignment: .center) {
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
                            
                            Text(String(hideNVotes ? "Hidden" : String(commentViewModel.comment.score + commentViewModel.comment.likes)))
                                .frame(width: 72, alignment: .center)
                                .commentInfo()
                            
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
                            .padding(.trailing, 16)
                            .buttonStyle(.borderless)
                            
                            Spacer()
                            
                            if let onToggleExpand, commentViewModel.comment.replies?.comments.count ?? -1 > 0 {
                                Button(action: {
                                    onToggleExpand()
                                }) {
                                    SwiftUI.Image(systemName: "chevron.up")
                                        .commentIconTemplateRendering()
                                        .commentIcon()
                                        .rotationEffect(.degrees(commentViewModel.comment.isCollasped ? 180 : 0))
                                        .animation(.easeInOut(duration: 0.25), value: commentViewModel.comment.isCollasped)
                                }
                                .padding(.trailing, 16)
                                .buttonStyle(.borderless)
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
                            .padding(.trailing, 16)
                            .buttonStyle(.borderless)
                            
                            ShareLink(item: "https://reddit.com" + commentViewModel.comment.permalink) {
                                SwiftUI.Image(systemName: "square.and.arrow.up")
                                    .commentIconTemplateRendering()
                                    .commentIcon()
                            }
                            .padding(.trailing, 16)
                            .buttonStyle(.borderless)
                            
                            if isInPostDetails {
                                Button(action: {
                                    onReply?()
                                }) {
                                    SwiftUI.Image(systemName: "arrowshape.turn.up.left.fill")
                                        .commentIconTemplateRendering()
                                        .commentIcon()
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                }
                
                if showCommentDivider {
                    Divider()
                }
            }
        }
        .contentShape(Rectangle())
        .background((commentViewModel.comment.isCollasped && fullyCollapseComment && commentViewModel.comment.hasExpandedBefore) || (commentViewModel.comment.isFilteredOut && !commentViewModel.comment.hasExpandedBefore) ? Color(hex: customThemeViewModel.currentCustomTheme.fullyCollapsedCommentBackgroundColor) : Color.clear)
        .onTapGesture {
            isToolbarHidden.toggle()
        }
    }
}
