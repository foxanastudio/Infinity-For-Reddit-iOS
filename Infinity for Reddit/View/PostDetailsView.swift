//
//  PostDetailsView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-23.
//

import SwiftUI
import Swinject
import GRDB
import Alamofire

struct PostDetailsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject private var commentSubmissionShareableViewModel: CommentSubmissionShareableViewModel
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @StateObject var playerManager = PlayerManager()
    @StateObject var postDetailsViewModel: PostDetailsViewModel
    
    @State private var showSortTypeSheet: Bool = false
    @State private var navigationBarMenuKey: UUID?
    @State private var sentCommentParent: CommentParent? = nil
    @State private var commentToBeEdited: Comment? = nil
    
    @AppStorage(InterfaceCommentUserDefaultsUtils.fullyCollapseCommentKey, store: .interfaceComment)
    private var fullyCollapseComment: Bool = false
    @AppStorage(InterfaceCommentUserDefaultsUtils.showAuthorAvatarKey, store: .interfaceComment)
    private var showAuthorAvatar: Bool = false
    
    private let account: Account
    private let isFromSubredditPostListing: Bool
    
    init(account: Account, postDetailsInput: PostDetailsInput, isFromSubredditPostListing: Bool, isContinueThread: Bool = false) {
        self.account = account
        self.isFromSubredditPostListing = isFromSubredditPostListing
        
        _postDetailsViewModel = StateObject(
            wrappedValue: PostDetailsViewModel(
                account: account,
                postDetailsInput: postDetailsInput,
                postDetailsRepository: PostDetailsRepository(),
                isContinueThread: isContinueThread
            )
        )
    }
    
    var body: some View {
        Group {
            List {
                if let post = postDetailsViewModel.post {
                    PostDetailsViewCard(account: account, post: post, isFromSubredditPostListing: isFromSubredditPostListing) {
                        sendComment()
                    }
                    .listPlainItemNoInsets()
                    .onAppear {
                        if post.subredditOrUserIconInPostDetails == nil {
                            Task {
                                await postDetailsViewModel.loadIcon(isFromSubredditPostListing: isFromSubredditPostListing)
                            }
                        }
                    }
                    
                    if case .postAndCommentId(_, let commentId) = postDetailsViewModel.postDetailsInput, commentId != nil {
                        TouchRipple(action: {
                            guard let post = postDetailsViewModel.post else { return }
                            postDetailsViewModel.postDetailsInput = .post(post)
                            postDetailsViewModel.refreshPostAndComments()
                        }) {
                            Text("Click here to browse all comments")
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .padding(16)
                                .colorAccentText()
                        }
                        .listPlainItemNoInsets()
                    }
                }
                
                if postDetailsViewModel.visibleComments.isEmpty {
                    if postDetailsViewModel.isInitialLoading || postDetailsViewModel.isInitialLoad {
                        ProgressIndicator()
                            .frame(maxWidth: .infinity)
                            .listPlainItem()
                    } else {
                        ZStack {
                            VStack(spacing: 8) {
                                SwiftUI.Image(systemName: "plus.circle")
                                    .primaryIcon()
                                
                                Text("No comments yet. Be the first to share your thoughts!")
                                    .primaryText()
                                    .multilineTextAlignment(.center)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                sendComment()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .listPlainItemNoInsets()
                    }
                } else {
                    ForEach(postDetailsViewModel.visibleComments, id: \.id) { commentItem in
                        if case let .comment(comment) = commentItem {
                            CommentViewCard(
                                account: account, comment: comment, isInPostDetails: true,
                                highlightComment: postDetailsViewModel.postDetailsInput.getHighlightCommentId == comment.id,
                                onToggleExpand: {
                                    if fullyCollapseComment {
                                        if comment.isCollasped {
                                            postDetailsViewModel.expandComments(comment: comment)
                                        } else {
                                            postDetailsViewModel.collapseComments(comment: comment)
                                        }
                                    } else {
                                        withAnimation {
                                            if comment.isCollasped {
                                                postDetailsViewModel.expandComments(comment: comment)
                                            } else {
                                                postDetailsViewModel.collapseComments(comment: comment)
                                            }
                                        }
                                    }
                                },
                                onReply: {
                                    let commentParent = CommentParent.comment(parentComment: comment)
                                    self.sentCommentParent = commentParent
                                    navigationManager.path.append(AppNavigation.submitComment(commentParent: commentParent))
                                },
                                onEdit: {
                                    self.commentToBeEdited = comment
                                    navigationManager.path.append(AppNavigation.editComment(commentToBeEdited: comment))
                                },
                                onDelete: {
                                    postDetailsViewModel.deleteComment(comment)
                                })
                            .listPlainItemNoInsets()
                            .id(ObjectIdentifier(comment))
                            .onLongPressGesture {
                                if fullyCollapseComment {
                                    if comment.isCollasped {
                                        postDetailsViewModel.expandComments(comment: comment)
                                    } else {
                                        postDetailsViewModel.collapseComments(comment: comment)
                                    }
                                } else {
                                    withAnimation {
                                        if comment.isCollasped {
                                            postDetailsViewModel.expandComments(comment: comment)
                                        } else {
                                            postDetailsViewModel.collapseComments(comment: comment)
                                        }
                                    }
                                }
                            }
                            .transition(.slide)
                            .onAppear {
                                if showAuthorAvatar {
                                    postDetailsViewModel.loadIcon(comment: comment)
                                }
                            }
                        } else if case let .more(commentMore) = commentItem {
                            CommentMoreViewCard(commentMore: commentMore)
                                .listPlainItemNoInsets()
                                .id(commentMore.id)
                                .onTapGesture {
                                    if commentMore.children.count > 0 {
                                        Task {
                                            await postDetailsViewModel.fetchMoreCommentsInCommentMore(commentMore: commentMore)
                                        }
                                    } else {
                                        // Continue thread
                                        if let postId = postDetailsViewModel.post?.id {
                                            navigationManager.path.append(
                                                AppNavigation.postDetailsWithId(
                                                    postId: postId,
                                                    commentId: commentMore.parentFullname.substring(from: 3),
                                                    isContinueThread: true
                                                )
                                            )
                                        }
                                    }
                                }
                        }
                    }
                    if postDetailsViewModel.hasMoreComments {
                        Text("Loading more comments")
                            .primaryText()
                            .task {
                                await postDetailsViewModel.fetchCommentsPagination()
                            }
                            .listPlainItem()
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .refreshable {
                await postDetailsViewModel.refreshPostAndCommentsWithContinuation()
            }
        }
        .onChange(of: commentSubmissionShareableViewModel.submittedComment) {
            if let sentComment = commentSubmissionShareableViewModel.submittedComment {
                if let sentCommentParent = self.sentCommentParent {
                    postDetailsViewModel.insertSubmittedComment(sentComment, commentParent: sentCommentParent)
                }
                commentSubmissionShareableViewModel.submittedComment = nil
                sentCommentParent = nil
            }
        }
        .onChange(of: commentSubmissionShareableViewModel.editedComment) {
            if let editedComment = commentSubmissionShareableViewModel.editedComment {
                if let commentToBeEdited = self.commentToBeEdited {
                    postDetailsViewModel.editComment(editedComment, commentToBeEdited: commentToBeEdited)
                }
                commentSubmissionShareableViewModel.editedComment = nil
                commentToBeEdited = nil
            }
        }
        .task(id: postDetailsViewModel.loadPostAndCommentsTaskId) {
            await postDetailsViewModel.initialLoadPostAndComments()
        }
        .themedList()
        .themedNavigationBar()
        .toolbar {
            NavigationBarMenu()
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Refresh") {
                    postDetailsViewModel.refreshPostAndComments()
                },
                
                NavigationBarMenuItem(title: "Sort") {
                    showSortTypeSheet = true
                },
                
                NavigationBarMenuItem(title: "Send comment") {
                    sendComment()
                }
            ])
        }
        .onDisappear {
            guard let navigationBarMenuKey else { return }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
        .sheet(isPresented: $showSortTypeSheet) {
            SortTypeKindSheet(
                sortTypeKindSource: OtherSortTypeKindSource.postDetails,
                currentSortTypeKind: postDetailsViewModel.sortTypeKind
            ) { sortTypeKind in
                postDetailsViewModel.changeSortTypeKind(sortTypeKind: sortTypeKind)
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    private func sendComment() {
        if let post = postDetailsViewModel.post {
            let commentParent = CommentParent.post(parentPost: post)
            self.sentCommentParent = commentParent
            navigationManager.path.append(AppNavigation.submitComment(commentParent: commentParent))
        }
    }
    
    private func editComment(_ comment: Comment) {
        
    }
}
