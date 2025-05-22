//
//  PostListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-04.
//

import SwiftUI
import Swinject
import GRDB
import Alamofire

struct PostListingView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var navigationManager: NavigationManager
    
    @StateObject var postListingViewModel: PostListingViewModel
    private let account: Account
    
    init(account: Account, postListingMetadata: PostListingMetadata) {
        self.account = account
        
        _postListingViewModel = StateObject(
            wrappedValue: PostListingViewModel(
                postListingMetadata: postListingMetadata,
                postListingRepository: PostListingRepository()
            )
        )
    }
    
    var body: some View {
        Group {
            if postListingViewModel.isInitialLoading || postListingViewModel.isInitialLoad {
                ProgressIndicator()
            } else if postListingViewModel.posts.isEmpty {
                Text("No posts")
            } else {
                List {
                    ForEach(postListingViewModel.posts, id: \.id) { post in
                        PostViewCard(account: account, post: post)
                            .id(post.id)
                            .listPlainItem()
                    }
                    if postListingViewModel.hasMorePages {
                        ProgressIndicator()
                            .task {
                                await postListingViewModel.loadPosts()
                            }
                            .listPlainItem()
                    }
                }.scrollBounceBehavior(.basedOnSize)
            }
        }
        .onChange(of: colorScheme) {
            //print(colorScheme == .dark)
        }
        .task {
            await postListingViewModel.initialLoadPosts()
        }
        .themedList()
    }
}
