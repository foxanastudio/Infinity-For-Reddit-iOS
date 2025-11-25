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
    @EnvironmentObject private var postEditingShareableViewModel: PostEditingShareableViewModel
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @StateObject var playerManager = PlayerManager()
    @StateObject var postDetailsViewModel: PostDetailsViewModel
    
    @FocusState private var focusedField: FieldType?
    
    @State private var showSortTypeSheet: Bool = false
    @State private var showSelectFlairSheet: Bool = false
    @State private var showPostModerationSheet: Bool = false
    @State private var navigationBarMenuKey: UUID?
    @State private var sentCommentParent: CommentParent? = nil
    @State private var commentToBeEdited: Comment? = nil
    @State private var activeAlert: ActiveAlert? = nil
    @State private var showActionBar: Bool = true
    @State private var showSearchBar: Bool = false
    @State private var listProxy: ScrollViewProxy?
    
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
                historyPostsRepository: HistoryPostsRepository(),
                flairRepository: FlairRepository(),
                postModerationRepository: PostModerationRepository(),
                isContinueThread: isContinueThread
            )
        )
    }
    
    var body: some View {
        RootView {
            ZStack(alignment: .bottom) {
                ScrollViewReader { proxy in
                    List {
                        if let post = postDetailsViewModel.post {
                            PostDetailsViewCard(account: account, post: post, isFromSubredditPostListing: isFromSubredditPostListing) {
                                sendComment()
                            }
                            .listPlainItemNoInsets()
                            .id(ObjectIdentifier(post))
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
                                        highlightComment: postDetailsViewModel.postDetailsInput.getHighlightCommentId == comment.id || postDetailsViewModel.searchedComment?.id == comment.id,
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
                                    .transition(.slide)
                                    .onAppear {
                                        postDetailsViewModel.insertIntoAppearedComments(commentItem)
                                        
                                        if showAuthorAvatar {
                                            postDetailsViewModel.loadIcon(comment: comment)
                                        }
                                    }
                                    .onDisappear {
                                        postDetailsViewModel.appearedComments.removeAll {
                                            $0.id == commentItem.id
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
                                Text("Loading more comments")
                                    .primaryText()
                                    .task {
                                        await postDetailsViewModel.fetchCommentsPagination()
                                    }
                                    .listPlainItem()
                            }
                        }
                    }
                    .themedList()
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
                            withAnimation {
                                showActionBar = true
                            }
                        case .interacting:
                            withAnimation {
                                showActionBar = false
                            }
                        default:
                            break
                        }
                    }
                }
                
                if showSearchBar {
                    HStack(spacing: 0) {
                        CustomTextField(
                            "Search",
                            text: $postDetailsViewModel.searchQuery,
                            singleLine: false,
                            keyboardType: .default,
                            autocapitalization: .never,
                            customTextFieldScheme: .fab,
                            showBorder: false,
                            showBackground: false,
                            fieldType: .search,
                            focusedField: $focusedField
                        )
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
                        
                        CustomDivider()
                            .frame(width: 2, height: 32)
                        
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
                        
                        CustomDivider()
                            .frame(width: 2, height: 32)
                        
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
                        postDetailsViewModel.toggleLock()
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
        .overlay(
            CustomAlert(
                title: activeAlert?.title ?? "",
                confirmButtonText: activeAlert?.confirmButtonText ?? "",
                buttonStyle: activeAlert?.buttonStyle ?? .info,
                isPresented: Binding(
                    get: { activeAlert != nil },
                    set: { newValue in
                        if !newValue {
                            activeAlert = nil
                        }
                    }
                )) {} onConfirm: {
                    if let alert = activeAlert {
                        switch alert {
                        case .deletePost:
                            postDetailsViewModel.deletePost()
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
                    
                    NavigationBarMenuItem(title: "Send comment") {
                        sendComment()
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
                    
                    NavigationBarMenuItem(title: "Send comment") {
                        sendComment()
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
                
                NavigationBarMenuItem(title: "Send comment") {
                    sendComment()
                },
                
                NavigationBarMenuItem(title: postDetailsViewModel.post?.hidden ?? false ? "Unhide post" : "Hide post") {
                    postDetailsViewModel.toggleHidePost {
                        setUpMenu()
                    }
                }
            ]
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

        var id: Int {
            hashValue
        }
        
        var title: String {
            switch self {
            case .deletePost:
                return "Delete Post?"
            }
        }
        
        var confirmButtonText: String {
            switch self {
            case .deletePost:
                return "Delete"
            }
        }
        
        var buttonStyle: AlertButtonStyle {
            switch self {
            case .deletePost:
                return .warning
            }
        }
    }
    
    private enum FieldType: Hashable {
        case search
    }
}
