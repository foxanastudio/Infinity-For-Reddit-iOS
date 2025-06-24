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
    
    @StateObject var commentListingViewModel: CommentListingViewModel
    
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
            if commentListingViewModel.isInitialLoading || commentListingViewModel.isInitialLoad {
                ProgressIndicator()
            } else if commentListingViewModel.comments.isEmpty {
                Text("No Comments")
            } else {
                List {
                    ForEach(commentListingViewModel.comments, id: \.id) { comment in
                        CommentViewCard(account: accountViewModel.account, comment: comment, isInPostDetails: false)
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
        .task {
            await commentListingViewModel.initialLoadComments()
        }
        .listStyle(.plain)
    }
}

