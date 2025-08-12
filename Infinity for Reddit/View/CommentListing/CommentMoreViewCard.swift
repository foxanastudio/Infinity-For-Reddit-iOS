//
//  CommentMoreViewCard.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-28.
//

import SwiftUI

struct CommentMoreViewCard: View {
    @AppStorage(InterfaceCommentUserDefaultsUtils.showCommentDividerKey, store: .interfaceCommentFilter)
    private var showCommentDivider: Bool = false
    
    let commentMore: CommentMore
    
    var body: some View {
        HStack(spacing: 0) {
            CommentIndentationView(depth: commentMore.depth)
            
            VStack(spacing: 0) {
                Text(commentMore.children.count > 0 ? "Load more comments" : "Continue Thread")
                    .commentText()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                
                if showCommentDivider {
                    Divider()
                }
            }
        }
        .contentShape(Rectangle())
    }
}
