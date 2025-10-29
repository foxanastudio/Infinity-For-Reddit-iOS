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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var navigationBarMenuManager: NavigationBarMenuManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    @StateObject var commentListingViewModel: CommentListingViewModel
    @State private var showSortTypeKindSheet: Bool = false
    @State private var showSortTypeTimeSheet: Bool = false
    @State private var upcomingSortTypeKind: SortType.Kind?
    @State private var navigationBarMenuKey: UUID?
    
    init(commentListingMetadata: CommentListingMetadata) {
        _commentListingViewModel = StateObject(
            wrappedValue: CommentListingViewModel(
                commentListingMetadata: commentListingMetadata,
                commentListingRepository: CommentListingRepository()
            )
        )
    }
    
    var body: some View {
        Group {
            if commentListingViewModel.comments.isEmpty {
                if commentListingViewModel.isInitialLoading || commentListingViewModel.isInitialLoad {
                    ProgressIndicator()
                } else {
                    Text("No Comments")
                }
            } else {
                List {
                    ForEach(commentListingViewModel.comments, id: \.id) { comment in
                        TouchRipple {
                            CommentViewCard(
                                account: accountViewModel.account,
                                comment: comment,
                                isInPostDetails: false
                            )
                            .onTapGesture {
                                navigationManager.path.append(
                                    AppNavigation.postDetailsWithId(postId: String(comment.linkId.dropFirst(3)), commentId: comment.id)
                                )
                            }
                        }
                        .listPlainItemNoInsets()
                        .id(comment.id)
                    }
                    if commentListingViewModel.hasMorePages {
                        ProgressIndicator()
                            .task {
                                await commentListingViewModel.loadComments()
                            }
                            .listPlainItem()
                    }
                }.scrollBounceBehavior(.basedOnSize)
            }
        }
        .onChange(of: colorScheme) {
            //print(colorScheme == .dark)
        }
        .task(id: commentListingViewModel.loadCommentsTaskId) {
            await commentListingViewModel.initialLoadComments()
        }
        .refreshable {
            await commentListingViewModel.refreshCommentsWithContinuation()
        }
        .listStyle(.plain)
        .onAppear {
            if let key = navigationBarMenuKey {
                navigationBarMenuManager.pop(key: key)
            }
            navigationBarMenuKey = navigationBarMenuManager.push([
                NavigationBarMenuItem(title: "Refresh") {
                    commentListingViewModel.refreshComments()
                },
                
                NavigationBarMenuItem(title: "Sort") {
                    showSortTypeKindSheet = true
                }
            ])
        }
        .onDisappear {
            guard let navigationBarMenuKey else { return }
            navigationBarMenuManager.pop(key: navigationBarMenuKey)
        }
        .sheet(isPresented: $showSortTypeKindSheet) {
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
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSortTypeTimeSheet) {
            SortTypeTimeSheet(
                sortTypeTimeSource: OtherSortTypeKindSource.commentListing,
                currentSortTypeTime: commentListingViewModel.sortType.time
            ) { sortTypeTime in
                if let upcomingSortTypeKind = upcomingSortTypeKind {
                    commentListingViewModel.changeSortType(sortType: SortType(type: upcomingSortTypeKind, time: sortTypeTime))
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

