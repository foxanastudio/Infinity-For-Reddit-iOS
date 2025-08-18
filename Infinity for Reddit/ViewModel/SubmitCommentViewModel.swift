//
//  SubmitCommentViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-17.
//

import Foundation
import MarkdownUI

class SubmitCommentViewModel: ObservableObject {
    let commentParent: CommentParent
    
    init(commentParent: CommentParent) {
        self.commentParent = commentParent
    }
}
