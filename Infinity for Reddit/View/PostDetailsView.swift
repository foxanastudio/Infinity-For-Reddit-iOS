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
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject private var commentSubmissionShareableViewModel: CommentSubmissionShareableViewModel
    @EnvironmentObject private var postEditingShareableViewModel: PostEditingShareableViewModel
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @EnvironmentObject private var accountViewModel: AccountViewModel
    
    @StateObject var postDetailsViewModel: PostDetailsViewModel
    
    @FocusState private var focusedField: FieldType?
    
    @State private var showSortTypeSheet: Bool = false
    @State private var showSelectFlairSheet: Bool = false
    @State private var showPostModerationSheet: Bool = false
    @State private var showCommentModerationSheet: Bool = false
    @State private var showPostOptionsSheet: Bool = false
    @State private var showPostShareSheet: Bool = false
    @State private var showCopyContentOptionsSheet: Bool = false
    @State private var titleToBeCopied: String?
    @State private var markdownToBeCopied: String = ""
    @State private var plainTextToBeCopied: String = ""
    @State private var textToBeSelectedAndCopiedItem: TextToBeSelectedAndCopiedItem?
    @State private var navigationBarMenuKey: UUID?
    @State private var sentCommentParent: CommentParent? = nil
    @State private var commentToBeEdited: Comment? = nil
    @State private var activeAlert: ActiveAlert? = nil
    @State private var showActionBar: Bool = true
    @State private var showSearchBar: Bool = false
    @State private var listProxy: ScrollViewProxy?
    @State private var commentToBeModerated: Comment?
    @State private var voteTask: Task<Void, Never>?
    
    @AppStorage(InterfaceCommentUserDefaultsUtils.fullyCollapseCommentKey, store: .interfaceComment)
    private var fullyCollapseComment: Bool = false
    @AppStorage(InterfaceCommentUserDefaultsUtils.showAuthorAvatarKey, store: .interfaceComment)
    private var showAuthorAvatar: Bool = false
    
    private let isFromSubredditPostListing: Bool
    private let playbackTimeToSeekToInitially: Double
    private let thingModerationRepository: ThingModerationRepositoryProtocol
    
    init(postDetailsInput: PostDetailsInput, isFromSubredditPostListing: Bool, isContinueThread: Bool = false, videoPlaybackTime: Double = 0) {
        self.isFromSubredditPostListing = isFromSubredditPostListing
        self.playbackTimeToSeekToInitially = videoPlaybackTime
        let thingModerationRepository = ThingModerationRepository()
        self.thingModerationRepository = thingModerationRepository
        
        _postDetailsViewModel = StateObject(
            wrappedValue: PostDetailsViewModel(
                postDetailsInput: postDetailsInput,
                postDetailsRepository: PostDetailsRepository(),
                historyPostsRepository: HistoryPostsRepository(),
                flairRepository: FlairRepository(),
                thingModerationRepository: thingModerationRepository,
                postRepository: PostRepository(),
                commentRepository: CommentRepository(),
                isContinueThread: isContinueThread
            )
        )
    }
    
    var body: some View {
        RootView {
            if let post = postDetailsViewModel.post {
                GeometryReader { geometryProxy in
                    ZStack(alignment: .bottom) {
                        HStack(spacing: 0) {
                            if geometryProxy.size.width > 500 {
                                List {
                                    PostDetailsItemView(
                                        postDetailsViewModel: postDetailsViewModel,
                                        post: post,
                                        isFromSubredditPostListing: isFromSubredditPostListing,
                                        playbackTimeToSeekToInitially: playbackTimeToSeekToInitially,
                                        onSendComment: sendComment,
                                        onLongPress: {
                                            showPostOptionsSheet = true
                                        },
                                        onLongPressOnContent: {
                                            titleToBeCopied = post.title
                                            markdownToBeCopied = post.selftext
                                            plainTextToBeCopied = post.selftextHtml
                                            showCopyContentOptionsSheet = true
                                        }
                                    )
                                    
                                    Spacer()
                                        .frame(height: 150)
                                        .listPlainItemNoInsets()
                                }
                                .themedList()
                                .scrollIndicators(.hidden)
                                .scrollBounceBehavior(.basedOnSize)
                            }
                            
                            ScrollViewReader { proxy in
                                List {
                                    if geometryProxy.size.width <= 500 {
                                        PostDetailsItemView(
                                            postDetailsViewModel: postDetailsViewModel,
                                            post: post,
                                            isFromSubredditPostListing: isFromSubredditPostListing,
                                            playbackTimeToSeekToInitially: playbackTimeToSeekToInitially,
                                            onSendComment: sendComment,
                                            onLongPress: {
                                                showPostOptionsSheet = true
                                            },
                                            onLongPressOnContent: {
                                                titleToBeCopied = post.title
                                                markdownToBeCopied = post.selftext
                                                plainTextToBeCopied = post.selftextHtml
                                                showCopyContentOptionsSheet = true
                                            }
                                        )
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
                                            switch commentItem {
                                            case .comment(let comment):
                                                CommentViewCard(
                                                    comment: comment,
                                                    isInPostDetails: true,
                                                    highlightComment: postDetailsViewModel.postDetailsInput.getHighlightCommentId == comment.id || postDetailsViewModel.searchedComment?.id == comment.id,
                                                    thingModerationRepository: thingModerationRepository,
                                                    onUpvote: {
                                                        postDetailsViewModel.voteComment(comment, vote: 1)
                                                    },
                                                    onDownvote: {
                                                        postDetailsViewModel.voteComment(comment, vote: -1)
                                                    },
                                                    onToggleSave: {
                                                        postDetailsViewModel.toggleSaveComment(comment, save: !comment.saved)
                                                    },
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
                                                        navigationManager.append(AppNavigation.submitComment(commentParent: commentParent))
                                                    },
                                                    onEdit: {
                                                        self.commentToBeEdited = comment
                                                        navigationManager.append(AppNavigation.editComment(commentToBeEdited: comment))
                                                    },
                                                    onDelete: {
                                                        postDetailsViewModel.deleteComment(comment)
                                                    },
                                                    onAddToCommentFilter: {
                                                        navigationManager.append(SettingsViewNavigation.commentFilter(commentToBeAdded: comment))
                                                    },
                                                    onModerate: {
                                                        commentToBeModerated = comment
                                                        showCommentModerationSheet = true
                                                    },
                                                    onCopy: {
                                                        titleToBeCopied = nil
                                                        markdownToBeCopied = comment.body
                                                        plainTextToBeCopied = comment.bodyHtml
                                                        showCopyContentOptionsSheet = true
                                                    }
                                                )
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
                                                .onAppear {
                                                    postDetailsViewModel.insertIntoAppearedComments(commentItem)
                                                    
                                                    if showAuthorAvatar {
                                                        postDetailsViewModel.loadIcon(comment: comment)
                                                    }
                                                }
                                                .onDisappear {
                                                    postDetailsViewModel.appearedComments.remove(id: commentItem.id)
                                                }
                                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                    if AccountViewModel.shared.account.isAnonymous() {
                                                        EmptyView()
                                                    } else {
                                                        Button {
                                                            postDetailsViewModel.voteComment(comment, vote: 1)
                                                        } label: {
                                                            SwiftUI.Image(systemName: "arrowshape.up")
                                                                .foregroundStyle(.white)
                                                        }
                                                        .tint(Color(hex: customThemeViewModel.currentCustomTheme.upvoted))
                                                    }
                                                }
                                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                                    if AccountViewModel.shared.account.isAnonymous() {
                                                        EmptyView()
                                                    } else {
                                                        Button {
                                                            postDetailsViewModel.voteComment(comment, vote: -1)
                                                        } label: {
                                                            SwiftUI.Image(systemName: "arrowshape.down")
                                                                .foregroundStyle(.white)
                                                        }
                                                        .tint(Color(hex: customThemeViewModel.currentCustomTheme.downvoted))
                                                    }
                                                }
                                            case .more(let commentMore):
                                                CommentMoreViewCard(commentMore: commentMore)
                                                    .listPlainItemNoInsets()
                                                    .id(ObjectIdentifier(commentMore))
                                                    .onTapGesture {
                                                        if commentMore.children.count > 0 {
                                                            Task {
                                                                await postDetailsViewModel.fetchMoreCommentsInCommentMore(commentMore: commentMore)
                                                            }
                                                        } else {
                                                            // Continue thread
                                                            if let postId = postDetailsViewModel.post?.id {
                                                                navigationManager.append(
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
                                            HStack {
                                                ProgressIndicator()
                                            }
                                            .frame(maxWidth: .infinity)
                                            .listPlainItemNoInsets()
                                            .task {
                                                await postDetailsViewModel.fetchCommentsPagination()
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                        .frame(height: 150)
                                        .listPlainItemNoInsets()
                                }
                                .transaction { $0.animation = nil }
                                .themedList()
                                .scrollIndicators(.hidden)
                                .scrollBounceBehavior(.basedOnSize)
                                .onAppear {
                                    self.listProxy = proxy
                                }
                                .refreshable {
                                    await postDetailsViewModel.refreshPostAndCommentsWithContinuation()
                                }
                                .onScrollPhaseChange { _, phase in
                                    switch phase {
                                    case .idle:
                                        if !showActionBar {
                                            withAnimation {
                                                showActionBar = true
                                            }
                                        }
                                    case .interacting:
                                        if showActionBar {
                                            withAnimation {
                                                showActionBar = false
                                            }
                                        }
                                    default:
                                        break
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        if showSearchBar {
                            HStack(spacing: 0) {
                                CustomTextField(
                                    "Search",
                                    text: $postDetailsViewModel.searchQuery,
                                    singleLine: true,
                                    keyboardType: .default,
                                    autocapitalization: .never,
                                    customTextFieldScheme: .fab,
                                    showBorder: false,
                                    showBackground: false,
                                    fieldType: .search,
                                    focusedField: $focusedField
                                )
                                .submitLabel(.search)
                                .onSubmit {
                                    if let listProxy, let commentItem = postDetailsViewModel.getNextSearchedComment() {
                                        scrollToComment(listProxy: listProxy, commentItem: commentItem)
                                    }
                                }
                                
                                SwiftUI.Image(systemName: "chevron.up")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16)
                                    .padding(16)
                                    .fabIcon()
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if let listProxy, let commentItem = postDetailsViewModel.getPreviousSearchedComment() {
                                            scrollToComment(listProxy: listProxy, commentItem: commentItem)
                                        }
                                    }
                                
                                SwiftUI.Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16)
                                    .padding(16)
                                    .fabIcon()
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if let listProxy, let commentItem = postDetailsViewModel.getNextSearchedComment() {
                                            scrollToComment(listProxy: listProxy, commentItem: commentItem)
                                        }
                                    }
                                
                                SwiftUI.Image(systemName: "xmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16)
                                    .padding(16)
                                    .fabIcon()
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            showSearchBar = false
                                            postDetailsViewModel.searchedComment = nil
                                            postDetailsViewModel.searchQuery = ""
                                        }
                                    }
                            }
                            .padding(.vertical, 16)
                            .padding(.leading, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: customThemeViewModel.currentCustomTheme.colorAccent))
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 8)
                            )
                            .padding(16)
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                            .transition(.move(edge: .bottom))
                            .zIndex(2)
                        } else if showActionBar {
                            HStack(spacing: 0) {
                                SwiftUI.Image(systemName: "chevron.up")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24)
                                    .padding(16)
                                    .fabIcon()
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if let listProxy {
                                            if let commentItem = postDetailsViewModel.getPreviousParentComment() {
                                                scrollToComment(listProxy: listProxy, commentItem: commentItem)
                                            }
                                        }
                                    }
                                
                                SwiftUI.Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24)
                                    .padding(16)
                                    .fabIcon()
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            showSearchBar = true
                                        }
                                    }
                                
                                SwiftUI.Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24)
                                    .padding(16)
                                    .fabIcon()
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if let listProxy {
                                            if let commentItem = postDetailsViewModel.getNextParentComment() {
                                                scrollToComment(listProxy: listProxy, commentItem: commentItem)
                                            }
                                        }
                                    }
                            }
                            .background(
                                Capsule()
                                    .fill(Color(hex: customThemeViewModel.currentCustomTheme.colorAccent))
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 8)
                            )
                            .padding(.bottom, 32)
                            .contentShape(Capsule())
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                        }
                    }
                    .showErrorUsingSnackbar(postDetailsViewModel.$error)
                }
            } else {
                ZStack {
                    if postDetailsViewModel.isInitialLoading {
                        ProgressIndicator()
                    } else if postDetailsViewModel.isInitialLoad, let error = postDetailsViewModel.error {
                        Text("Unable to load post and comments. Tap to retry. Error: \(error.localizedDescription)")
                            .primaryText()
                            .padding(16)
                            .onTapGesture {
                                postDetailsViewModel.refreshPostAndComments()
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onChange(of: postDetailsViewModel.post) {
            setUpMenu()
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
        .onChange(of: postEditingShareableViewModel.editedPost) { _, newValue in
            if let editedPost = newValue {
                postDetailsViewModel.editPost(editedPost)
                postEditingShareableViewModel.editedPost = nil
            }
        }
        .onChange(of: postDetailsViewModel.showMediaDownloadFinishedMessageTrigger) {
            snackbarManager.showSnackbar(.info("Download complete."))
        }
        .onChange(of: postDetailsViewModel.showAllGalleryMediaDownloadFinishedMessageTrigger) {
            snackbarManager.showSnackbar(.info("Gallery download complete."))
        }
        .task(id: postDetailsViewModel.loadPostAndCommentsTaskId) {
            await postDetailsViewModel.initialLoadPostAndComments()
        }
        .themedNavigationBar()
        .toolbar {
            NavigationBarMenu()
        }
        .onAppear {
            setUpMenu()
            showActionBar = true
        }
        .onDisappear {
            guard let navigationBarMenuKey else { return }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
        .onChange(of: postDetailsViewModel.showSensitiveContentWarningTrigger) { _, newValue in
            if newValue {
                activeAlert = .sensitiveContentWarning
            }
        }
        .wrapContentSheet(isPresented: $showSortTypeSheet) {
            SortTypeKindSheet(
                sortTypeKindSource: OtherSortTypeKindSource.postDetails,
                currentSortTypeKind: postDetailsViewModel.sortTypeKind
            ) { sortTypeKind in
                postDetailsViewModel.changeSortTypeKind(sortTypeKind: sortTypeKind)
            }
        }
        .wrapContentSheet(isPresented: $showSelectFlairSheet) {
            SelectPostFlairSheet(flairs: postDetailsViewModel.flairs) { flair in
                postDetailsViewModel.selectFlair(flair)
            }
        }
        .wrapContentSheet(isPresented: $showPostOptionsSheet) {
            if let post = postDetailsViewModel.post {
                PostOptionsSheet(
                    post: post,
                    onComment: {
                        navigationManager.append(AppNavigation.submitComment(commentParent: .post(parentPost: post)))
                    },
                    onShare: {
                        showPostShareSheet = true
                    },
                    onCopy: {
                        titleToBeCopied = post.title
                        markdownToBeCopied = post.selftext
                        plainTextToBeCopied = post.selftextHtml
                        showCopyContentOptionsSheet = true
                    },
                    onAddToPostFilter: {
                        navigationManager.append(SettingsViewNavigation.postFilter(postToBeAdded: post))
                    },
                    onToggleHidePost: {
                        postDetailsViewModel.toggleHidePost {
                            setUpMenu()
                        }
                    },
                    onCrosspost: {
                        navigationManager.append(AppNavigation.crosspost(postToBeCrossposted: post))
                    },
                    onDownloadMedia: {
                        postDetailsViewModel.downloadMedia()
                    },
                    onDownloadAllGalleryMedia: {
                        postDetailsViewModel.downloadAllGalleryMedia()
                    },
                    onReport: {
                        if AccountViewModel.shared.account.isAnonymous() {
                            navigationManager.openLink("https://www.reddit.com/report")
                        } else {
                            navigationManager.append(AppNavigation.report(subredditName: post.subreddit, thingFullname: post.name))
                        }
                    },
                    onModeration: {
                        showPostModerationSheet = true
                    }
                )
            } else {
                EmptyView()
            }
        }
        .wrapContentSheet(isPresented: $showPostModerationSheet) {
            if let post = postDetailsViewModel.post {
                PostModerationSheet(
                    post: post,
                    onApprove: {
                        postDetailsViewModel.approvePost()
                    },
                    onRemove: {
                        postDetailsViewModel.removePost(isSpam: false)
                    },
                    onMarkAsSpam: {
                        postDetailsViewModel.removePost(isSpam: true)
                    },
                    onToggleStickyPost: {
                        postDetailsViewModel.toggleSticky()
                    },
                    onToggleLock: {
                        postDetailsViewModel.toggleLockPost()
                    },
                    onToggleSensitive: {
                        postDetailsViewModel.toggleSensitive {
                            setUpMenu()
                        }
                    },
                    onToggleSpoiler: {
                        postDetailsViewModel.toggleSpoiler {
                            setUpMenu()
                        }
                    },
                    onToggleDistinguishAsModerator: {
                        postDetailsViewModel.toggleDistinguishAsMod()
                    }
                )
            } else {
                EmptyView()
            }
        }
        .wrapContentSheet(isPresented: $showCommentModerationSheet) {
            if let commentToBeModerated {
                CommentModerationSheet(
                    comment: commentToBeModerated,
                    onApprove: {
                        postDetailsViewModel.approveComment(commentToBeModerated)
                    },
                    onRemove: {
                        postDetailsViewModel.removeComment(commentToBeModerated, isSpam: false)
                    },
                    onMarkAsSpam: {
                        postDetailsViewModel.removeComment(commentToBeModerated, isSpam: true)
                    },
                    onToggleLock: {
                        postDetailsViewModel.toggleLockComment(commentToBeModerated)
                    }
                )
            } else {
                EmptyView()
            }
        }
        .wrapContentSheet(isPresented: $showPostShareSheet) {
            if let post = postDetailsViewModel.post {
                PostShareSheet(post: post)
            } else {
                EmptyView()
            }
        }
        .wrapContentSheet(isPresented: $showCopyContentOptionsSheet) {
            CopyContentOptionsSheet(
                title: titleToBeCopied,
                markdown: markdownToBeCopied,
                plainText: plainTextToBeCopied,
                onCopyEntireTitle: {
                    snackbarManager.showSnackbar(.info("Copied"))
                },
                onCopyTitle: {
                    textToBeSelectedAndCopiedItem = TextToBeSelectedAndCopiedItem(title: titleToBeCopied)
                },
                onCopyEntireMarkdown: {
                    snackbarManager.showSnackbar(.info("Copied"))
                },
                onCopyMarkdown: {
                    textToBeSelectedAndCopiedItem = TextToBeSelectedAndCopiedItem(content: markdownToBeCopied)
                },
                onCopyPlainText: {
                    textToBeSelectedAndCopiedItem = TextToBeSelectedAndCopiedItem(content: plainTextToBeCopied)
                }
            )
        }
        .sheet(item: $textToBeSelectedAndCopiedItem) { item in
            CopyContentSheet(
                content: item.title ?? item.content
            )
        }
        .overlay(
            CustomAlert(
                title: activeAlert?.title ?? "",
                subtitle: activeAlert?.subTitle,
                dismissButtonText: activeAlert?.dismissButtonText ?? "",
                confirmButtonText: activeAlert?.confirmButtonText ?? "",
                buttonStyle: activeAlert?.buttonStyle ?? .info,
                showDismissButton: activeAlert?.showDismissButton ?? true,
                canDismissByTapOutside: activeAlert?.canDismissByTapOutside ?? true,
                isPresented: Binding(
                    get: { activeAlert != nil },
                    set: { newValue in
                        if !newValue {
                            activeAlert = nil
                        }
                    }
                )
            ) {} onConfirm: {
                    if let alert = activeAlert {
                        switch alert {
                        case .deletePost:
                            postDetailsViewModel.deletePost()
                        case .sensitiveContentWarning:
                            dismiss()
                        }
                    }
                }
        )
    }
    
    private func setUpMenu() {
        if let key = navigationBarMenuKey {
            navigationBarMenuManager.pop(key: key)
        }
        
        var menuItems: [NavigationBarMenuItem]
        if AccountViewModel.shared.account.username == postDetailsViewModel.post?.author {
            if postDetailsViewModel.post?.canEditBody == true {
                menuItems = [
                    NavigationBarMenuItem(title: "Refresh") {
                        postDetailsViewModel.refreshPostAndComments()
                    },
                    
                    NavigationBarMenuItem(title: "Sort") {
                        showSortTypeSheet = true
                    },
                    
                    NavigationBarMenuItem(title: postDetailsViewModel.post?.hidden ?? false ? "Unhide post" : "Hide post") {
                        postDetailsViewModel.toggleHidePost {
                            setUpMenu()
                        }
                    },
                    
                    NavigationBarMenuItem(title: "Edit post") {
                        editPost()
                    },
                    
                    NavigationBarMenuItem(title: "Delete post") {
                        withAnimation(.linear(duration: 0.2)) {
                            activeAlert = .deletePost
                        }
                    },
                    
                    NavigationBarMenuItem(title: postDetailsViewModel.post?.over18 ?? false ? "Unmark Sensitive" : "Mark Sensitive") {
                        postDetailsViewModel.toggleSensitive {
                            setUpMenu()
                        }
                    },
                    
                    NavigationBarMenuItem(title: postDetailsViewModel.post?.spoiler ?? false ? "Unmark Spoiler" : "Mark Spoiler") {
                        postDetailsViewModel.toggleSpoiler {
                            setUpMenu()
                        }
                    },
                    
                    NavigationBarMenuItem(title: "Edit Flair") {
                        postDetailsViewModel.fetchFlairs()
                        showSelectFlairSheet = true
                    }
                ]
            } else {
                menuItems = [
                    NavigationBarMenuItem(title: "Refresh") {
                        postDetailsViewModel.refreshPostAndComments()
                    },
                    
                    NavigationBarMenuItem(title: "Sort") {
                        showSortTypeSheet = true
                    },
                    
                    NavigationBarMenuItem(title: postDetailsViewModel.post?.hidden ?? false ? "Unhide post" : "Hide post") {
                        postDetailsViewModel.toggleHidePost {
                            setUpMenu()
                        }
                    },
                    
                    NavigationBarMenuItem(title: "Delete post") {
                        withAnimation(.linear(duration: 0.2)) {
                            activeAlert = .deletePost
                        }
                    },
                    
                    NavigationBarMenuItem(title: postDetailsViewModel.post?.over18 ?? false ? "Unmark Sensitive" : "Mark Sensitive") {
                        postDetailsViewModel.toggleSensitive {
                            setUpMenu()
                        }
                    },
                    
                    NavigationBarMenuItem(title: postDetailsViewModel.post?.spoiler ?? false ? "Unmark Spoiler" : "Mark Spoiler") {
                        postDetailsViewModel.toggleSpoiler {
                            setUpMenu()
                        }
                    },
                    
                    NavigationBarMenuItem(title: "Edit Flair") {
                        postDetailsViewModel.fetchFlairs()
                        showSelectFlairSheet = true
                    }
                ]
            }
        } else {
            menuItems = [
                NavigationBarMenuItem(title: "Refresh") {
                    postDetailsViewModel.refreshPostAndComments()
                },
                
                NavigationBarMenuItem(title: "Sort") {
                    showSortTypeSheet = true
                },
                
                NavigationBarMenuItem(title: postDetailsViewModel.post?.hidden ?? false ? "Unhide post" : "Hide post") {
                    postDetailsViewModel.toggleHidePost {
                        setUpMenu()
                    }
                }
            ]
        }
        
        if !accountViewModel.account.isAnonymous() && postDetailsViewModel.post?.canReply == true {
            menuItems.append(
                NavigationBarMenuItem(title: "Send comment") {
                    sendComment()
                }
            )
        }
        
        if postDetailsViewModel.post?.isCrosspostable ?? false {
            menuItems.append(
                NavigationBarMenuItem(title: "Crosspost") {
                    guard let post = postDetailsViewModel.post else {
                        return
                    }
                    navigationManager.append(AppNavigation.crosspost(postToBeCrossposted: post))
                }
            )
        }
        
        if postDetailsViewModel.post?.canModPost ?? false {
            menuItems.append(
                NavigationBarMenuItem(title: "Moderate") {
                    guard postDetailsViewModel.post != nil else {
                        return
                    }
                    
                    showPostModerationSheet = true
                }
            )
        }
        
        menuItems.append(contentsOf: [
            NavigationBarMenuItem(title: "Add to Post Filter") {
                guard let post = postDetailsViewModel.post else {
                    return
                }
                navigationManager.append(SettingsViewNavigation.postFilter(postToBeAdded: post))
            },
            
            NavigationBarMenuItem(title: "Report") {
                guard let post = postDetailsViewModel.post else {
                    return
                }
                
                if AccountViewModel.shared.account.isAnonymous() {
                    navigationManager.openLink("https://www.reddit.com/report")
                } else {
                    navigationManager.append(AppNavigation.report(subredditName: post.subreddit, thingFullname: post.name))
                }
            }
        ])
        
        navigationBarMenuKey = navigationBarMenuManager.push(menuItems)
    }
    
    private func sendComment() {
        if let post = postDetailsViewModel.post {
            let commentParent = CommentParent.post(parentPost: post)
            self.sentCommentParent = commentParent
            navigationManager.append(AppNavigation.submitComment(commentParent: commentParent))
        }
    }
    
    private func editPost() {
        if let post = postDetailsViewModel.post {
            navigationManager.append(AppNavigation.editPost(post: post))
        }
    }
    
    // Don't scroll to CommentMore
    private func scrollToComment(listProxy: ScrollViewProxy, commentItem: CommentItem) {
        switch commentItem {
        case .comment(let comment):
            withAnimation {
                listProxy.scrollTo(ObjectIdentifier(comment), anchor: .top)
            }
        case .more:
            break
        }
    }
    
    private enum ActiveAlert: Identifiable {
        case deletePost
        case sensitiveContentWarning

        var id: Int {
            hashValue
        }
        
        var title: String {
            switch self {
            case .deletePost:
                return "Delete Post?"
            case .sensitiveContentWarning:
                return "Sensivite Content"
            }
        }
        
        var subTitle: String? {
            switch self {
            case .deletePost:
                return nil
            case .sensitiveContentWarning:
                return "This post may contain sensitive content. You have disabled sensitive content in your settings, so you can only go back."
            }
        }
        
        var dismissButtonText: String {
            switch self {
            case .deletePost:
                return "Cancel"
            case .sensitiveContentWarning:
                return "View Anyway"
            }
        }
        
        var confirmButtonText: String {
            switch self {
            case .deletePost:
                return "Delete"
            case .sensitiveContentWarning:
                return "Go Back"
            }
        }
        
        var buttonStyle: AlertButtonStyle {
            switch self {
            case .deletePost:
                return .warning
            case .sensitiveContentWarning:
                return .info
            }
        }
        
        var showDismissButton: Bool {
            switch self {
            case .deletePost:
                return true
            case .sensitiveContentWarning:
                return false
            }
        }
        
        var canDismissByTapOutside: Bool {
            switch self {
            case .deletePost:
                return true
            case .sensitiveContentWarning:
                return false
            }
        }
    }
    
    private enum FieldType: Hashable {
        case search
    }
}

private struct PostDetailsItemView: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @ObservedObject var postDetailsViewModel: PostDetailsViewModel
    
    @State var voteTask: Task<Void, Never>?
    
    let post: Post
    let isFromSubredditPostListing: Bool
    let playbackTimeToSeekToInitially: Double
    let onSendComment: () -> Void
    let onLongPress: () -> Void
    let onLongPressOnContent: () -> Void
    
    var body: some View {
        PostDetailsViewCard(
            post: post,
            isFromSubredditPostListing: isFromSubredditPostListing,
            playbackTimeToSeekToInitially: playbackTimeToSeekToInitially,
            onUpvote: {
                voteTask?.cancel()
                voteTask = Task {
                    await postDetailsViewModel.votePost(vote: 1)
                }
            },
            onDownvote: {
                voteTask?.cancel()
                voteTask = Task {
                    await postDetailsViewModel.votePost(vote: -1)
                }
            },
            onToggleSave: {
                await postDetailsViewModel.toggleSavePost(save: !post.saved)
            },
            onSendComment: onSendComment,
            onLongPress: {
                onLongPress()
            },
            onLongPressOnContent: {
                onLongPressOnContent()
            }
        )
        .listPlainItemNoInsets()
        .id(ObjectIdentifier(post))
        .onAppear {
            if post.subredditOrUserIconInPostDetails == nil {
                Task {
                    await postDetailsViewModel.loadPostIcon(isFromSubredditPostListing: isFromSubredditPostListing)
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                voteTask?.cancel()
                voteTask = Task {
                    await postDetailsViewModel.votePost(vote: 1)
                }
            } label: {
                SwiftUI.Image(systemName: "arrowshape.up")
                    .foregroundStyle(.white)
            }
            .tint(Color(hex: customThemeViewModel.currentCustomTheme.upvoted))
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                voteTask?.cancel()
                voteTask = Task {
                    await postDetailsViewModel.votePost(vote: -1)
                }
            } label: {
                SwiftUI.Image(systemName: "arrowshape.down")
                    .foregroundStyle(.white)
            }
            .tint(Color(hex: customThemeViewModel.currentCustomTheme.downvoted))
        }
    }
}
