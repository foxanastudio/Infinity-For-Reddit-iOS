//
//  PostDetailsCommentsCache.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-04-12.
//

import IdentifiedCollections
import Foundation

class PostDetailsCommentsCache: NSObject, NSDiscardableContent {
    let post: Post
    let visibleComments: IdentifiedArrayOf<CommentItem>
    let allComments: IdentifiedArrayOf<CommentItem>
    let commentMore: CommentMore?
    let commentFilter: CommentFilter?
    let scrolledCommentItem: CommentItem?
    let lastLoadedSortTypeKind: SortType.Kind
    let hasMoreComments: Bool
    
    init(
        post: Post,
        visibleComments: IdentifiedArrayOf<CommentItem>,
        allComments: IdentifiedArrayOf<CommentItem>,
        commentMore: CommentMore?,
        commentFilter: CommentFilter?,
        scrolledCommentItem: CommentItem?,
        lastLoadedSortTypeKind: SortType.Kind,
        hasMoreComments: Bool
    ) {
        self.post = post
        self.visibleComments = visibleComments
        self.allComments = allComments
        self.commentMore = commentMore
        self.commentFilter = commentFilter
        self.scrolledCommentItem = scrolledCommentItem
        self.lastLoadedSortTypeKind = lastLoadedSortTypeKind
        self.hasMoreComments = hasMoreComments
    }
    
    func beginContentAccess() -> Bool {
        return true
    }
    
    func endContentAccess() {
        
    }
    
    func discardContentIfPossible() {
        
    }
    
    func isContentDiscarded() -> Bool {
        return false
    }
}
