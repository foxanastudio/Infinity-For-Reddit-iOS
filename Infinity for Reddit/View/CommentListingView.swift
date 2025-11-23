//
//  CommentListingView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-15.
//

import SwiftUI
import Swinject
import GRDB
import Alamofire

struct CommentListingView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject private var commentSubmissionShareableViewModel: CommentSubmissionShareableViewModel
    
    @StateObject var commentListingViewModel: CommentListingViewModel
    @State private var showSortTypeKindSheet: Bool = false
    @State private var showSortTypeTimeSheet: Bool = false
    @State private var upcomingSortTypeKind: SortType.Kind?
    @State private var navigationBarMenuKey: UUID?
    @State private var commentToBeEdited: Comment? = nil
    
    private let commentListingMetadata: CommentListingMetadata
    private let onScroll: (() -> Void)?
    
    init(commentListingMetadata: CommentListingMetadata, onScroll: (() -> Void)? = nil) {
        self.commentListingMetadata = commentListingMetadata
        self.onScroll = onScroll
        _commentListingViewModel = StateObject(
            wrappedValue: CommentListingViewModel(
                commentListingMetadata: commentListingMetadata,
                commentListingRepository: CommentListingRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            if commentListingViewModel.comments.isEmpty {
                if commentListingViewModel.isInitialLoading || commentListingViewModel.isInitialLoad {
                    ProgressIndicator()
                } else {
                    Text("No Comments")
                }
            } else {
                List {
                    ForEach(commentListingViewModel.comments, id: \.id) { comment in
                        TouchRipple(action: {
                            navigationManager.append(
                                AppNavigation.postDetailsWithId(postId: String(comment.linkId.dropFirst(3)), commentId: comment.id)
                            )
                        }) {
                            CommentViewCard(
                                account: accountViewModel.account,
                                comment: comment,
                                isInPostDetails: false,
                                onEdit: {
                                    self.commentToBeEdited = comment
                                    navigationManager.append(AppNavigation.editComment(commentToBeEdited: comment))
                                },
                                onDelete: {
                                    commentListingViewModel.deleteComment(comment)
                                },
                                onAddToCommentFilter: {
                                    navigationManager.append(SettingsViewNavigation.commentFilter(commentToBeAdded: comment))
                                }
                            )
                        }
                        .listPlainItemNoInsets()
                        .id(ObjectIdentifier(comment))
                    }
                    if commentListingViewModel.hasMorePages {
                        ProgressIndicator()
                            .task {
                                await commentListingViewModel.loadComments()
                            }
                            .listPlainItem()
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .applyIf(onScroll != nil) {
                    $0.onScrollPhaseChange { oldPhase, newPhase, context in
                        if newPhase == .interacting {
                            onScroll?()
                        }
                    }
                }
            }
        }
        .task(id: commentListingViewModel.loadCommentsTaskId) {
            await commentListingViewModel.initialLoadComments()
        }
        .refreshable {
            await commentListingViewModel.refreshCommentsWithContinuation()
        }
        .listStyle(.plain)
        .onChange(of: commentSubmissionShareableViewModel.editedComment) {
            if let editedComment = commentSubmissionShareableViewModel.editedComment {
                if let commentToBeEdited = self.commentToBeEdited {
                    commentListingViewModel.editComment(editedComment, commentToBeEdited: commentToBeEdited)
                }
                commentSubmissionShareableViewModel.editedComment = nil
                commentToBeEdited = nil
            }
        }
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            let menu: [NavigationBarMenuItem]
            switch commentListingMetadata.commentListingType {
            case .user:
                menu = [
                    NavigationBarMenuItem(title: "Refresh") {
                        commentListingViewModel.refreshComments()
                    },
                    
                    NavigationBarMenuItem(title: "Sort") {
                        showSortTypeKindSheet = true
                    }
                ]
            case .userSaved:
                menu = [
                    NavigationBarMenuItem(title: "Refresh") {
                        commentListingViewModel.refreshComments()
                    }
                ]
            }
            navigationBarMenuKey = navigationBarMenuManager.push(menu)
        }
        .onDisappear {
            guard let navigationBarMenuKey else {
                return
            }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
        .wrapContentSheet(isPresented: $showSortTypeKindSheet) {
            SortTypeKindSheet(
                sortTypeKindSource: OtherSortTypeKindSource.commentListing,
                currentSortTypeKind: commentListingViewModel.sortType.type
            ) { sortTypeKind in
                if (sortTypeKind.hasTime) {
                    upcomingSortTypeKind = sortTypeKind
                    showSortTypeTimeSheet = true
                } else {
                    commentListingViewModel.changeSortTypeKind(sortTypeKind: sortTypeKind)
                }
            }
        }
        .wrapContentSheet(isPresented: $showSortTypeTimeSheet) {
            SortTypeTimeSheet(
                sortTypeTimeSource: OtherSortTypeKindSource.commentListing,
                currentSortTypeTime: commentListingViewModel.sortType.time
            ) { sortTypeTime in
                if let upcomingSortTypeKind = upcomingSortTypeKind {
                    commentListingViewModel.changeSortType(sortType: SortType(type: upcomingSortTypeKind, time: sortTypeTime))
                }
            }
        }
    }
}

