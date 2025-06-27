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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @StateObject var playerManager = PlayerManager()
    @StateObject var postDetailsViewModel: PostDetailsViewModel
    private let account: Account
    private let post: Post
    
    init(account: Account, post: Post) {
        self.account = account
        self.post = post
        
        _postDetailsViewModel = StateObject(
            wrappedValue: PostDetailsViewModel(
                account: account,
                post: post,
                postDetailsRepository: PostDetailsRepository()
            )
        )
    }
    
    var body: some View {
        Group {
            List {
                PostDetailsViewCard(account: account, post: post)
                    .listPlainItemNoInsets()
                
                if postDetailsViewModel.isInitialLoading || postDetailsViewModel.isInitialLoad {
                    ProgressIndicator()
                        .listPlainItem()
                } else if postDetailsViewModel.visibleComments.isEmpty {
                    Text("No comments")
                        .listPlainItem()
                } else {
                    ForEach(postDetailsViewModel.visibleComments, id: \.id) { comment in
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
                    }
                    if postDetailsViewModel.hasMoreComments {
                        Text("Loading more comments")
                            .task {
                                await postDetailsViewModel.fetchComments()
                            }
                            .listPlainItem()
                    }
                }
            }.scrollBounceBehavior(.basedOnSize)
        }
        .onChange(of: colorScheme) {
            //print(colorScheme == .dark)
        }
        .task {
            await postDetailsViewModel.fetchComments()
        }
        .themedList()
        .themedNavigationBar()
        .toolbar {
            NavigationBarMenu()
        }
    }
}
