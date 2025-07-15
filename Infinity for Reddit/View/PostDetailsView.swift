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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @StateObject var playerManager = PlayerManager()
    @StateObject var postDetailsViewModel: PostDetailsViewModel
    @State private var showSortTypeSheet: Bool = false
    @State private var navigationBarMenuKey: UUID?
    
    private let account: Account
    private let isFromSubredditPostListing: Bool
    
    init(account: Account, postDetailsInput: PostDetailsInput, isFromSubredditPostListing: Bool) {
        self.account = account
        self.isFromSubredditPostListing = isFromSubredditPostListing
        
        _postDetailsViewModel = StateObject(
            wrappedValue: PostDetailsViewModel(
                account: account,
                postDetailsInput: postDetailsInput,
                postDetailsRepository: PostDetailsRepository()
            )
        )
    }
    
    var body: some View {
        Group {
            List {
                if let post = postDetailsViewModel.post {
                    PostDetailsViewCard(account: account, post: post, isFromSubredditPostListing: isFromSubredditPostListing)
                        .listPlainItemNoInsets()
                        .onAppear {
                            if post.subredditOrUserIconInPostDetails == nil {
                                Task {
                                    await postDetailsViewModel.loadIcon(isFromSubredditPostListing: isFromSubredditPostListing)
                                }
                            }
                        }
                }
                
                if postDetailsViewModel.visibleComments.isEmpty {
                    if postDetailsViewModel.isInitialLoading || postDetailsViewModel.isInitialLoad {
                        ProgressIndicator()
                            .frame(maxWidth: .infinity)
                            .listPlainItem()
                    } else {
                        Text("No comments")
                            .listPlainItem()
                    }
                } else {
                    ForEach(postDetailsViewModel.visibleComments, id: \.id) { commentItem in
                        if case let .comment(comment) = commentItem {
                            CommentViewCard(account: account, comment: comment, isInPostDetails: true, onToggleExpand: {
                                withAnimation {
                                    if comment.isCollasped {
                                        postDetailsViewModel.expandComments(comment: comment)
                                    } else {
                                        postDetailsViewModel.collapseComments(comment: comment)
                                    }
                                }
                            })
                            .listPlainItemNoInsets()
                            .id(comment.id)
                            .onLongPressGesture {
                                withAnimation {
                                    if comment.isCollasped {
                                        postDetailsViewModel.expandComments(comment: comment)
                                    } else {
                                        postDetailsViewModel.collapseComments(comment: comment)
                                    }
                                }
                            }
                            .transition(.slide)
                            .onAppear {
                                postDetailsViewModel.loadIcon(comment: comment)
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
                                        
                                    }
                                }
                        }
                    }
                    if postDetailsViewModel.hasMoreComments {
                        Text("Loading more comments")
                            .task {
                                await postDetailsViewModel.fetchPostAndComments()
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
        .onChange(of: colorScheme) {
            //print(colorScheme == .dark)
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
}
