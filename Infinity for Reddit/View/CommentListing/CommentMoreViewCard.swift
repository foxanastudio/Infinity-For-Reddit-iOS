//
//  CommentMoreViewCard.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-28.
//

import SwiftUI

struct CommentMoreViewCard: View {
    @AppStorage(InterfaceCommentUserDefaultsUtils.showCommentDividerKey, store: .interfaceComment)
    private var showCommentDivider: Bool = false
    
    @ObservedObject var commentMore: CommentMore
    
    var body: some View {
        HStack(spacing: 0) {
            CommentIndentationView(depth: commentMore.depth)
            
            VStack(spacing: 0) {
                Text(text)
                    .commentText()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                
                if showCommentDivider {
                    CustomDivider()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .contentShape(Rectangle())
    }
    
    var text: String {
        switch commentMore.loadState {
        case .idle:
            return commentMore.commentMoreType == .normal ? "Load more comments" : "Continue Thread"
        case .loading:
            return "Loading..."
        case .loaded:
            // CommentMoreViewCard will be removed at this point. So we don't care about it.
            return ""
        case .failed(_):
            return "Failed to load more comments. Tap to retry."
        }
    }
}
