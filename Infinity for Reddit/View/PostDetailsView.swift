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
    
    init(account: Account, post: Post) {
        self.account = account
        
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
            if postDetailsViewModel.isInitialLoading {
                Text("Is loading")
            } else if postDetailsViewModel.comments.isEmpty {
                Text("No comments")
            } else {
                Text(String(postDetailsViewModel.comments.count))
//                List {
//                    ForEach(postDetailsViewModel.posts, id: \.id) { post in
//                        PostViewCard(account: account, post: post)
//                            .id(post.id)
//                    }
//                    if postDetailsViewModel.hasMorePages {
//                        Text("Loading more pages")
//                            .onAppear {
//                                postDetailsViewModel.loadPosts()
//                            }
//                    }
//                }.scrollBounceBehavior(.basedOnSize)
            }
        }
        .onChange(of: colorScheme) {
            //print(colorScheme == .dark)
        }
        .onAppear {
            postDetailsViewModel.fetchComments()
        }
        .themedList()
    }
}
