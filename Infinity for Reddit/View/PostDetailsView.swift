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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
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
                PostViewCard(account: account, post: post)
                
                if postDetailsViewModel.isInitialLoading {
                    Text("Is loading")
                } else if postDetailsViewModel.comments.isEmpty {
                    Text("No comments")
                } else {
                    ForEach(postDetailsViewModel.comments, id: \.id) { comment in
                        CommentViewCard(account: account, comment: comment)
                            .id(comment.id)
                    }
                    if postDetailsViewModel.hasMoreComments {
                        Text("Loading more comments")
                            .onAppear {
                                postDetailsViewModel.fetchComments()
                            }
                    }
                }
            }.scrollBounceBehavior(.basedOnSize)
            
            
        }
        .onChange(of: colorScheme) {
            //print(colorScheme == .dark)
        }
        .onAppear {
            postDetailsViewModel.fetchComments()
        }
        .themedList()
        .themedNavigationBar()
    }
}
